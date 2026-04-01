-- ============================================================
-- ETAPA 2: Criação das tabelas do sistema
-- ============================================================
-- A ordem de criação respeita as chaves estrangeiras (FK):
-- tabelas sem dependências são criadas primeiro.
--
-- Ordem:
--   1. clientes   (sem FK)
--   2. produtos   (sem FK)
--   3. pedidos    (FK → clientes)
--   4. expedicao  (FK → pedidos)
--   5. compra     (FK → clientes, produtos, pedidos)
--
-- ============================================================


-- ------------------------------------------------------------
-- 2.1 clientes
-- Armazena os dados do comprador.
-- Chave primária: codigoComprador
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes (
    codigoComprador VARCHAR(50)  NOT NULL PRIMARY KEY,
    nomeComprador   VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL
);


-- ------------------------------------------------------------
-- 2.2 produtos
-- Armazena os dados do produto.
-- Chave primária: SKU
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS produtos (
    SKU         VARCHAR(50)   NOT NULL PRIMARY KEY,
    UPC         VARCHAR(50),
    nomeProduto VARCHAR(100)  NOT NULL,
    valor       DECIMAL(10,2) NOT NULL
);


-- ------------------------------------------------------------
-- 2.3 pedidos
-- Armazena o pedido consolidado com o valor total calculado.
-- Chave primária: codigoPedido
-- FK → clientes (codigoComprador)
--
-- Regra de negócio do valorTotal:
--   1 produto:  (valor × qtd) + frete
--   N produtos: (val1×qtd1) + (val2×qtd2) + ... + frete
--   O frete é somado uma única vez por pedido.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedidos (
    codigoPedido    VARCHAR(50)   NOT NULL PRIMARY KEY,
    dataPedido      DATE          NOT NULL,
    codigoComprador VARCHAR(50)   NOT NULL,
    valorTotal      DECIMAL(10,2) NOT NULL,
    frete           DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (codigoComprador) REFERENCES clientes(codigoComprador)
);



-- ------------------------------------------------------------
-- 2.4 expedicao
-- Armazena o endereço de entrega do pedido.
-- Chave primária: codigoPedido (1 endereço por pedido)
-- FK → pedidos (codigoPedido)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS expedicao (
    codigoPedido VARCHAR(50)  NOT NULL PRIMARY KEY,
    endereco     VARCHAR(200) NOT NULL,
    CEP          VARCHAR(20)  NOT NULL,
    UF           VARCHAR(5)   NOT NULL,
    pais         VARCHAR(50)  NOT NULL,
    FOREIGN KEY (codigoPedido) REFERENCES pedidos(codigoPedido)
);


-- ------------------------------------------------------------
-- 2.5 compra
-- Tabela associativa: relaciona pedido, produto e comprador.
-- Chave primária composta: codigoPedido + SKU
--   → garante que o mesmo produto não apareça duplicado
--     no mesmo pedido.
-- FK → pedidos, produtos e clientes
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS compra (
    codigoPedido    VARCHAR(50) NOT NULL,
    SKU             VARCHAR(50) NOT NULL,
    codigoComprador VARCHAR(50) NOT NULL,
    qtd             INT         NOT NULL,
    PRIMARY KEY (codigoPedido, SKU),
    FOREIGN KEY (codigoPedido)    REFERENCES pedidos(codigoPedido),
    FOREIGN KEY (SKU)             REFERENCES produtos(SKU),
    FOREIGN KEY (codigoComprador) REFERENCES clientes(codigoComprador)
);

