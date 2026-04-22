-- =============================================================================
-- FASE 1: CRIAÇÃO DA TABELA DE CARGA (STAGING)
-- =============================================================================

DROP TABLE IF EXISTS staging_pedidos;

CREATE TEMP TABLE staging_pedidos (
    order_id             VARCHAR(50),
    order_item_id        VARCHAR(50),
    purchase_date        VARCHAR(50),
    payments_date        VARCHAR(50),
    buyer_email          VARCHAR(255),
    buyer_name           VARCHAR(255),
    cpf                  VARCHAR(20),
    buyer_phone_number   VARCHAR(50),
    sku                  VARCHAR(100),
    upc                  VARCHAR(50),
    product_name         VARCHAR(255),
    quantity_purchased   VARCHAR(20),
    currency             VARCHAR(10),
    item_price           VARCHAR(20),
    ship_service_level   VARCHAR(50),
    ship_address_1       VARCHAR(255),
    ship_address_2       VARCHAR(255),
    ship_address_3       VARCHAR(255),
    ship_city            VARCHAR(100),
    ship_state           VARCHAR(50),
    ship_postal_code     VARCHAR(20),
    ship_country         VARCHAR(50)
);

-- Comando de carga (simulação). No ambiente real, o caminho do arquivo deve ser ajustado.
/*
COPY staging_pedidos FROM '/caminho/do/arquivo/pedidos_marketplace.csv' DELIMITER ',' CSV HEADER;
*/