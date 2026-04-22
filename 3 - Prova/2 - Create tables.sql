-- =============================================================================
-- FASE 2: CRIAÇÃO DAS TABELAS DEFINITIVAS
-- =============================================================================

-- 1. Clientes (A chave primária será o CPF)
CREATE TABLE IF NOT EXISTS clientes (
    cpf                  VARCHAR(20) PRIMARY KEY,
    nome                 VARCHAR(255) NOT NULL,
    email                VARCHAR(255),
    telefone             VARCHAR(50),
    endereco             VARCHAR(500),
    cidade               VARCHAR(100),
    estado               VARCHAR(50),
    cep                  VARCHAR(20),
    pais                 VARCHAR(50)
);

-- 2. Produtos (A chave primária será o SKU)
CREATE TABLE IF NOT EXISTS produtos (
    sku                  VARCHAR(100) PRIMARY KEY,
    upc                  VARCHAR(50),
    nome_produto         VARCHAR(255) NOT NULL,
    estoque_atual        INT DEFAULT 0,
    lote_reposicao       INT DEFAULT 10
);

-- 3. Pedidos (Capa do pedido)
CREATE TABLE IF NOT EXISTS pedidos (
    order_id             VARCHAR(50) PRIMARY KEY,
    cpf_cliente          VARCHAR(20) REFERENCES clientes(cpf),
    data_compra          TIMESTAMP,
    data_pagamento       TIMESTAMP,
    nivel_servico_frete  VARCHAR(50),
    status               VARCHAR(20) DEFAULT 'Pendente'
);

-- 4. Itens do Pedido
CREATE TABLE IF NOT EXISTS itens_pedido (
    order_item_id        VARCHAR(50) PRIMARY KEY,
    order_id             VARCHAR(50) REFERENCES pedidos(order_id),
    sku                  VARCHAR(100) REFERENCES produtos(sku),
    quantidade           INT NOT NULL,
    moeda                VARCHAR(10),
    preco_unitario       NUMERIC(10, 2) NOT NULL
);