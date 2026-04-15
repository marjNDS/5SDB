-- =============================================================================
-- BLOCO 2: TABELA TEMPORÁRIA DE STAGING
-- Criada a cada execução para receber o arquivo bruto sem transformação.
-- O uso de TEMP garante que ela seja descartada ao final da sessão.
-- =============================================================================

DROP TABLE IF EXISTS staging_pedidos;

CREATE TEMP TABLE staging_pedidos (
    codigo_pedido    VARCHAR(50),
    data_pedido      VARCHAR(20),   -- recebido como texto; convertido depois
    sku              VARCHAR(100),
    upc              VARCHAR(50),
    nome_produto     VARCHAR(255),
    qtd              INT,
    valor            VARCHAR(20),   -- recebido como texto (ex: "43,22"); convertido depois
    frete            VARCHAR(20),   -- idem
    email            VARCHAR(255),
    codigo_comprador VARCHAR(50),
    nome_comprador   VARCHAR(255),
    endereco         VARCHAR(500),
    cep              VARCHAR(20),
    uf               CHAR(2),
    pais             VARCHAR(100)
);
