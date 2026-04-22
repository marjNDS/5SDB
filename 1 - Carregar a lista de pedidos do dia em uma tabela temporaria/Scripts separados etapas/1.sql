-- =============================================================================
-- BLOCO 1: CRIAÇÃO DAS TABELAS DO SISTEMA
-- Executar apenas uma vez. Se as tabelas já existirem, este bloco é ignorado
-- graças ao IF NOT EXISTS.
-- =============================================================================

-- Clientes: um registro por comprador único
CREATE TABLE IF NOT EXISTS clientes (
    codigo_comprador  VARCHAR(50)  PRIMARY KEY,
    nome              VARCHAR(255) NOT NULL,
    email             VARCHAR(255) NOT NULL,
    endereco          VARCHAR(500),
    cep               VARCHAR(20),
    uf                CHAR(2),
    pais              VARCHAR(100)
);

-- Produtos: um registro por SKU (chave interna da empresa)
CREATE TABLE IF NOT EXISTS produtos (
    sku               VARCHAR(100) PRIMARY KEY,
    upc               VARCHAR(50),
    nome_produto      VARCHAR(255) NOT NULL,
    valor             NUMERIC(10, 2) NOT NULL,
    estoque_atual     INT DEFAULT 0
);


-- Compra: representa a transação financeira consolidada de um pedido inteiro.
-- Um pedido pode ter N itens; a compra registra o total + frete.
CREATE TABLE IF NOT EXISTS compra (
    codigo_pedido  VARCHAR(50)  PRIMARY KEY,
    data_pedido    DATE         NOT NULL,
    codigo_comprador VARCHAR(50) NOT NULL REFERENCES clientes(codigo_comprador),
    frete          NUMERIC(10, 2) NOT NULL,
    valor_total    NUMERIC(10, 2) NOT NULL  -- calculado: soma(valor*qtd) + frete
);

-- Pedidos: cada linha representa um item dentro de uma compra.
-- Um mesmo codigo_pedido pode aparecer N vezes aqui (um por SKU).
CREATE TABLE IF NOT EXISTS pedidos (
    id             SERIAL       PRIMARY KEY,
    codigo_pedido  VARCHAR(50)  NOT NULL REFERENCES compra(codigo_pedido),
    sku            VARCHAR(100) NOT NULL REFERENCES produtos(sku),
    quantidade     INT          NOT NULL,
    valor_unitario NUMERIC(10, 2) NOT NULL
);

-- Expedição: dados de entrega por pedido (um por compra)
CREATE TABLE IF NOT EXISTS expedicao (
    id             SERIAL      PRIMARY KEY,
    codigo_pedido  VARCHAR(50) NOT NULL REFERENCES compra(codigo_pedido),
    endereco       VARCHAR(500),
    cep            VARCHAR(20),
    uf             CHAR(2),
    pais           VARCHAR(100)
);

-- Produtos em falta: SKUs que foram pedidos mas não constam na tabela produtos.
-- Esses registros precisam ser providenciados antes de processar o pedido.
CREATE TABLE IF NOT EXISTS produtos_em_falta (
    id             SERIAL      PRIMARY KEY,
    codigo_pedido  VARCHAR(50),
    sku            VARCHAR(100),
    upc            VARCHAR(50),
    nome_produto   VARCHAR(255),
    quantidade     INT,
    data_registro  TIMESTAMP   DEFAULT NOW()
);