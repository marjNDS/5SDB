-- =============================================================================
-- BLOCO T1: POPULAR O ESTOQUE DE PRODUTOS
-- Cadastra 4 SKUs que aparecem nos pedidos de teste, incluindo o saldo de estoque.
-- O SKU 'eletro999rio' é propositalmente omitido.
-- O SKU 'limite001rio' recebe apenas 2 unidades para testar a falta de saldo.
-- =============================================================================

INSERT INTO produtos (sku, upc, nome_produto, valor, estoque_atual) VALUES
    ('brinq456rio', '456', 'quebra-cabeca',  43.22, 50),
    ('brinq789rio', '789', 'jogo',           43.22, 50),
    ('roupa123rio', '123', 'camisa',         47.25, 50),
    ('limite001rio', '001', 'produto-limite', 10.00, 2)
-- Se o produto já existir (re-execução do teste), ignora o conflito
ON CONFLICT (sku) DO NOTHING;

-- =============================================================================
-- BLOCO T2: CRIAR E POPULAR A STAGING COM OS DADOS DE TESTE
-- Replica os dados do pedidos.txt e adiciona linhas extras para testar as falhas.
--
-- Cenários cobertos:
--   abc123 → 2 itens (quebra-cabeça + jogo)         → pedido com N produtos
--   abc789 → 1 item  (camisa, qtd=2)                → pedido com 1 produto
--   abc741 → 1 item  (jogo)                         → pedido com 1 produto
--   abc888 → 1 item  (estoque insuficiente)         → deve ir p/ falta
--   abc999 → 1 item  (eletro999rio sem estoque)     → deve ir p/ falta
-- =============================================================================

DROP TABLE IF EXISTS staging_pedidos;

CREATE TEMP TABLE staging_pedidos (
    codigo_pedido    VARCHAR(50),
    data_pedido      VARCHAR(20),
    sku              VARCHAR(100),
    upc              VARCHAR(50),
    nome_produto     VARCHAR(255),
    qtd              INT,
    valor            VARCHAR(20),
    frete            VARCHAR(20),
    email            VARCHAR(255),
    codigo_comprador VARCHAR(50),
    nome_comprador   VARCHAR(255),
    endereco         VARCHAR(500),
    cep              VARCHAR(20),
    uf               CHAR(2),
    pais             VARCHAR(100),
    valor_num        NUMERIC(10,2),
    frete_num        NUMERIC(10,2)
);

-- Dados espelhados
INSERT INTO staging_pedidos (
    codigo_pedido, data_pedido, sku, upc, nome_produto,
    qtd, valor, frete, email, codigo_comprador,
    nome_comprador, endereco, cep, uf, pais
) VALUES
    -- Pedido abc123: 2 itens → valor total = (43,22*1 + 43,22*1) + 5,32 = 91,76
    ('abc123','2024-03-19','brinq456rio','456','quebra-cabeca',1,'43,22','5,32','samir@gmail.com','123','Samir','Rua Exemplo 1','21212322','RJ','Brasil'),
    ('abc123','2024-03-19','brinq789rio','789','jogo',         1,'43,22','5,32','samir@gmail.com','123','Samir','Rua Exemplo 1','21212322','RJ','Brasil'),

    -- Pedido abc789: 1 item, qtd=2 → valor total = (47,25*2) + 6,21 = 100,71
    ('abc789','2024-03-20','roupa123rio','123','camisa',        2,'47,25','6,21','teste@gmail.com','789','Fulano','Rua Exemplo 2','14784520','RJ','Brasil'),

    -- Pedido abc741: 1 item → valor total = (43,22*1) + 5,32 = 48,54
    ('abc741','2024-03-21','brinq789rio','789','jogo',          1,'43,22','5,32','samir@gmail.com','123','Samir','Rua Exemplo 1','21212322','RJ','Brasil'),

    -- Pedido abc888: SKU com estoque insuficiente (tenta comprar 5, só tem 2) → deve ir p/ produtos_em_falta
    ('abc888','2024-03-21','limite001rio','001','produto-limite',5,'10,00','5,00','teste@gmail.com','789','Fulano','Rua Exemplo 2','14784520','RJ','Brasil'),

    -- Pedido abc999: SKU inexistente no estoque → deve ir para produtos_em_falta
    ('abc999','2024-03-21','eletro999rio','999','televisao',    1,'1200,00','30,00','samir@gmail.com','123','Samir','Rua Exemplo 1','21212322','RJ','Brasil');

-- Converte valores monetários de texto (vírgula) para NUMERIC (ponto)
UPDATE staging_pedidos
SET
    valor_num = REPLACE(valor, ',', '.')::NUMERIC(10,2),
    frete_num = REPLACE(frete, ',', '.')::NUMERIC(10,2);

-- =============================================================================
-- BLOCO T3: EXECUTAR O PROCESSAMENTO (replica os blocos do script principal)
-- =============================================================================

-- Produtos sem cadastro OU sem saldo suficiente -> produtos_em_falta
INSERT INTO produtos_em_falta (
    codigo_pedido, sku, upc, nome_produto, quantidade, data_registro
)
SELECT
    s.codigo_pedido, s.sku, s.upc, s.nome_produto, s.qtd, NOW()
FROM staging_pedidos s
LEFT JOIN produtos p ON p.sku = s.sku
WHERE p.sku IS NULL OR s.qtd > p.estoque_atual;

-- Remove da staging os itens sem cadastro ou saldo insuficiente
DELETE FROM staging_pedidos
WHERE sku NOT IN (SELECT sku FROM produtos)
   OR qtd > (SELECT estoque_atual FROM produtos WHERE sku = staging_pedidos.sku);

-- Clientes
INSERT INTO clientes (codigo_comprador, nome, email, endereco, cep, uf, pais)
SELECT DISTINCT ON (codigo_comprador)
    codigo_comprador, nome_comprador, email, endereco, cep, uf, pais
FROM staging_pedidos
ON CONFLICT (codigo_comprador) DO UPDATE SET
    nome  = EXCLUDED.nome,
    email = EXCLUDED.email;

-- Compra (valor total calculado)
INSERT INTO compra (codigo_pedido, data_pedido, codigo_comprador, frete, valor_total)
SELECT
    s.codigo_pedido,
    s.data_pedido::DATE,
    s.codigo_comprador,
    MAX(s.frete_num),
    SUM(p.valor * s.qtd) + MAX(s.frete_num)
FROM staging_pedidos s
JOIN produtos p ON p.sku = s.sku
GROUP BY s.codigo_pedido, s.data_pedido, s.codigo_comprador
ON CONFLICT (codigo_pedido) DO NOTHING;

-- Itens do pedido
INSERT INTO pedidos (codigo_pedido, sku, quantidade, valor_unitario)
SELECT s.codigo_pedido, s.sku, s.qtd, p.valor
FROM staging_pedidos s
JOIN produtos p ON p.sku = s.sku
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos pd
    WHERE pd.codigo_pedido = s.codigo_pedido AND pd.sku = s.sku
);

-- Expedição
INSERT INTO expedicao (codigo_pedido, endereco, cep, uf, pais)
SELECT DISTINCT ON (s.codigo_pedido)
    s.codigo_pedido, s.endereco, s.cep, s.uf, s.pais
FROM staging_pedidos s
JOIN compra c ON c.codigo_pedido = s.codigo_pedido
WHERE NOT EXISTS (
    SELECT 1 FROM expedicao e WHERE e.codigo_pedido = s.codigo_pedido
);

-- =============================================================================
-- BLOCO T4: VERIFICAÇÕES
-- Compare a saída real com o esperado para validar cada exigência.
-- =============================================================================

-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 1 — Dados chegaram nas tabelas corretas?
-- Esperado: 2 clientes, 4 produtos, 3 compras, 4 itens de pedido, 3 expedições
-- ----------------------------------------------------------------------------
SELECT 'clientes'        AS tabela, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'produtos',                  COUNT(*)           FROM produtos
UNION ALL
SELECT 'compra',                    COUNT(*)           FROM compra
UNION ALL
SELECT 'pedidos (itens)',           COUNT(*)           FROM pedidos
UNION ALL
SELECT 'expedicao',                 COUNT(*)           FROM expedicao;

-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 2 — Cálculo do valor total dos pedidos processados com sucesso
-- ----------------------------------------------------------------------------
SELECT
    codigo_pedido,
    frete,
    valor_total,
    CASE
        WHEN codigo_pedido = 'abc123' AND valor_total = 91.76  THEN 'OK'
        WHEN codigo_pedido = 'abc789' AND valor_total = 100.71 THEN 'OK'
        WHEN codigo_pedido = 'abc741' AND valor_total = 48.54  THEN 'OK'
        ELSE 'FALHOU'
    END AS resultado
FROM compra
WHERE codigo_pedido IN ('abc123', 'abc789', 'abc741')
ORDER BY codigo_pedido;

-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 3 — Itens sem estoque ou saldo insuficiente foram isolados?
-- Esperado: 2 registros (abc999 e abc888) na tabela produtos_em_falta.
--           Ambos NÃO devem aparecer nas tabelas de sistema (compra e pedidos).
-- ----------------------------------------------------------------------------
SELECT 'produtos_em_falta' AS verificacao, codigo_pedido, sku, nome_produto, quantidade
FROM produtos_em_falta
WHERE codigo_pedido IN ('abc999', 'abc888')
ORDER BY codigo_pedido;

-- Confirma que os itens barrados não vazaram
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'OK — abc888 e abc999 ausentes em compra'
         ELSE 'FALHOU — vazamento para a tabela compra'
    END AS resultado_compra
FROM compra WHERE codigo_pedido IN ('abc999', 'abc888');

SELECT
    CASE WHEN COUNT(*) = 0 THEN 'OK — abc888 e abc999 ausentes em pedidos'
         ELSE 'FALHOU — vazamento para a tabela pedidos'
    END AS resultado_pedidos
FROM pedidos WHERE codigo_pedido IN ('abc999', 'abc888');

-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 4 — Pedidos ordenados do mais caro ao mais barato
-- Esperado (ordem): abc789 (100,71) → abc123 (91,76) → abc741 (48,54)
-- ----------------------------------------------------------------------------
SELECT
    c.codigo_pedido,
    cl.nome       AS cliente,
    c.valor_total,
    ROW_NUMBER() OVER (ORDER BY c.valor_total DESC) AS posicao,
    CASE ROW_NUMBER() OVER (ORDER BY c.valor_total DESC)
        WHEN 1 THEN CASE WHEN c.codigo_pedido = 'abc789' THEN 'OK' ELSE 'FALHOU' END
        WHEN 2 THEN CASE WHEN c.codigo_pedido = 'abc123' THEN 'OK' ELSE 'FALHOU' END
        WHEN 3 THEN CASE WHEN c.codigo_pedido = 'abc741' THEN 'OK' ELSE 'FALHOU' END
    END AS resultado
FROM compra c
JOIN clientes cl ON cl.codigo_comprador = c.codigo_comprador
ORDER BY c.valor_total DESC;

-- =============================================================================
-- BLOCO T5: LIMPEZA — remove todos os dados inseridos pelo teste
-- =============================================================================

DELETE FROM expedicao         WHERE codigo_pedido IN ('abc123','abc789','abc741');
DELETE FROM pedidos           WHERE codigo_pedido IN ('abc123','abc789','abc741');
DELETE FROM compra            WHERE codigo_pedido IN ('abc123','abc789','abc741');
DELETE FROM produtos_em_falta WHERE codigo_pedido IN ('abc999', 'abc888');
DELETE FROM clientes          WHERE codigo_comprador IN ('123','789');
DELETE FROM produtos          WHERE sku IN ('brinq456rio','brinq789rio','roupa123rio', 'limite001rio');
