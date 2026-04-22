-- =============================================================================
-- BLOCO 5: SEPARAR PRODUTOS SEM ESTOQUE OU COM QUANTIDADE INSUFICIENTE
-- Identificamos os itens cujo SKU não existe em 'produtos' ou cuja
-- quantidade pedida supera o estoque atual. 
-- =============================================================================

-- Insere na tabela de falta os itens sem cadastro OU sem saldo suficiente
INSERT INTO produtos_em_falta (
    codigo_pedido, sku, upc, nome_produto, quantidade, data_registro
)
SELECT
    s.codigo_pedido,
    s.sku,
    s.upc,
    s.nome_produto,
    s.qtd,
    NOW()
FROM staging_pedidos s
LEFT JOIN produtos p ON p.sku = s.sku
-- Condição atualizada: O SKU não existe (NULL) OU a demanda é maior que o estoque
WHERE p.sku IS NULL OR s.qtd > p.estoque_atual;

-- Remove da staging os itens problemáticos para que não sejam processados
DELETE FROM staging_pedidos
WHERE sku NOT IN (SELECT sku FROM produtos)
   OR qtd > (SELECT estoque_atual FROM produtos WHERE sku = staging_pedidos.sku);



-- =============================================================================
-- BLOCO 6: INSERIR / ATUALIZAR CLIENTES
-- Usa INSERT ... ON CONFLICT para evitar duplicatas: se o cliente já existe,
-- atualiza os dados cadastrais com as informações mais recentes do arquivo.
-- =============================================================================

INSERT INTO clientes (
    codigo_comprador, nome, email, endereco, cep, uf, pais
)
-- DISTINCT ON garante um único registro por comprador mesmo que ele
-- apareça em várias linhas da staging (vários itens no mesmo pedido)
SELECT DISTINCT ON (codigo_comprador)
    codigo_comprador,
    nome_comprador,
    email,
    endereco,
    cep,
    uf,
    pais
FROM staging_pedidos
ON CONFLICT (codigo_comprador)
DO UPDATE SET
    nome  = EXCLUDED.nome,
    email = EXCLUDED.email;


-- =============================================================================
-- BLOCO 7: INSERIR COMPRA (TRANSAÇÃO CONSOLIDADA)
-- Calcula o valor total de cada pedido conforme a regra de negócio:
--   - 1 produto : valor * qtd + frete
--   - N produtos: soma(valor * qtd) + frete
-- A regra é a mesma expressão em ambos os casos; a distinção no enunciado
-- é apenas conceitual — matematicamente SUM(valor*qtd)+frete cobre os dois.
-- =============================================================================

INSERT INTO compra (
    codigo_pedido, data_pedido, codigo_comprador, frete, valor_total
)
SELECT
    s.codigo_pedido,
    s.data_pedido::DATE,
    s.codigo_comprador,
    -- O frete é o mesmo em todas as linhas do pedido; pegamos o primeiro valor
    MAX(s.frete_num)                            AS frete,
    -- Valor total = soma de (valor unitário do produto * quantidade) + frete
    SUM(p.valor * s.qtd) + MAX(s.frete_num)    AS valor_total
FROM staging_pedidos s
-- JOIN com produtos para garantir que usamos o valor oficial do cadastro,
-- não o valor informado no arquivo (que pode estar desatualizado)
JOIN produtos p ON p.sku = s.sku
GROUP BY
    s.codigo_pedido,
    s.data_pedido,
    s.codigo_comprador
ON CONFLICT (codigo_pedido) DO NOTHING;  -- pedido já existente é ignorado


-- =============================================================================
-- BLOCO 8: INSERIR ITENS EM PEDIDOS
-- Uma linha por SKU dentro de cada pedido.
-- Evita duplicatas verificando se o par (codigo_pedido, sku) já existe.
-- =============================================================================

INSERT INTO pedidos (
    codigo_pedido, sku, quantidade, valor_unitario
)
SELECT
    s.codigo_pedido,
    s.sku,
    s.qtd,
    p.valor   -- valor oficial do cadastro de produtos
FROM staging_pedidos s
JOIN produtos p ON p.sku = s.sku
-- Não insere se esse item já foi registrado para este pedido
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos pd
    WHERE pd.codigo_pedido = s.codigo_pedido
      AND pd.sku = s.sku
);


-- =============================================================================
-- BLOCO 9: INSERIR EXPEDIÇÃO
-- Um registro por pedido único (não por item).
-- Evita duplicatas verificando se o codigo_pedido já existe em expedicao.
-- =============================================================================

INSERT INTO expedicao (
    codigo_pedido, endereco, cep, uf, pais
)
SELECT DISTINCT ON (s.codigo_pedido)
    s.codigo_pedido,
    s.endereco,
    s.cep,
    s.uf,
    s.pais
FROM staging_pedidos s
JOIN compra c ON c.codigo_pedido = s.codigo_pedido
WHERE NOT EXISTS (
    SELECT 1
    FROM expedicao e
    WHERE e.codigo_pedido = s.codigo_pedido
);