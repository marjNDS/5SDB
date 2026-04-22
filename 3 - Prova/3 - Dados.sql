-- =============================================================================
-- FASE 3: DISTRIBUIÇÃO DOS DADOS (RESPEITANDO CHAVES ESTRANGEIRAS)
-- =============================================================================

-- 1. Inserir Clientes Novos
-- Agrupamos pelo CPF para garantir que cada cliente só tente ser inserido uma vez.
INSERT INTO clientes (cpf, nome, email, telefone, endereco, cidade, estado, cep, pais)
SELECT DISTINCT ON (cpf)
    cpf,
    buyer_name,
    buyer_email,
    buyer_phone_number,
    TRIM(CONCAT_WS(', ', ship_address_1, ship_address_2, ship_address_3)),
    ship_city,
    ship_state,
    ship_postal_code,
    ship_country
FROM staging_pedidos
WHERE cpf IS NOT NULL
ON CONFLICT (cpf) DO NOTHING;


-- 2. Inserir Produtos Novos
-- Agrupamos pelo SKU. Novos produtos entram com estoque zero.
INSERT INTO produtos (sku, upc, nome_produto)
SELECT DISTINCT ON (sku)
    sku,
    upc,
    product_name
FROM staging_pedidos
WHERE sku IS NOT NULL
ON CONFLICT (sku) DO NOTHING;


-- 3. Inserir Pedidos
-- Agrupamos pelo order_id. Fazemos o cast das datas.
INSERT INTO pedidos (order_id, cpf_cliente, data_compra, data_pagamento, nivel_servico_frete)
SELECT DISTINCT ON (order_id)
    order_id,
    cpf,
    -- Converte a string de data do CSV para o tipo TIMESTAMP do banco
    CAST(purchase_date AS TIMESTAMP),
    CAST(payments_date AS TIMESTAMP),
    ship_service_level
FROM staging_pedidos
WHERE order_id IS NOT NULL
ON CONFLICT (order_id) DO NOTHING;


-- 4. Inserir Itens do Pedido
-- Aqui não usamos DISTINCT, pois cada linha na staging é um item único.
-- Fazemos o cast de quantidade e preço.
INSERT INTO itens_pedido (order_item_id, order_id, sku, quantidade, moeda, preco_unitario)
SELECT 
    order_item_id,
    order_id,
    sku,
    CAST(quantity_purchased AS INT),
    currency,
    -- Substitui possível vírgula por ponto antes de converter para NUMERIC
    CAST(REPLACE(item_price, ',', '.') AS NUMERIC(10,2))
FROM staging_pedidos
WHERE order_item_id IS NOT NULL
ON CONFLICT (order_item_id) DO NOTHING;