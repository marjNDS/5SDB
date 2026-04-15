-- =============================================================================
-- BLOCO T2: CRIAR E POPULAR A STAGING COM OS DADOS DE TESTE
-- Replica os dados do pedidos.txt e adiciona uma linha extra com um SKU
-- inexistente ('eletro999rio') para acionar a exigência [3].
--
-- Cenários cobertos:
--   abc123 → 2 itens (quebra-cabeça + jogo)         → pedido com N produtos [2]
--   abc789 → 1 item  (camisa, qtd=2)                → pedido com 1 produto  [2]
--   abc741 → 1 item  (jogo)                         → pedido com 1 produto  [2]
--   abc999 → 1 item  (eletro999rio sem estoque)     → deve ir p/ falta      [3]
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

-- Dados espelhados do pedidos.txt
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

    -- Pedido abc999: SKU inexistente no estoque → deve ir para produtos_em_falta [3]
    ('abc999','2024-03-21','eletro999rio','999','televisao',    1,'1200,00','30,00','samir@gmail.com','123','Samir','Rua Exemplo 1','21212322','RJ','Brasil');

-- Converte valores monetários de texto (vírgula) para NUMERIC (ponto)
UPDATE staging_pedidos
SET
    valor_num = REPLACE(valor, ',', '.')::NUMERIC(10,2),
    frete_num = REPLACE(frete, ',', '.')::NUMERIC(10,2);
