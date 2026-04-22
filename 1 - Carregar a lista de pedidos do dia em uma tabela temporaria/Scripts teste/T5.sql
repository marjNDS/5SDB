-- =============================================================================
-- BLOCO T5: LIMPEZA — remove todos os dados inseridos pelo teste
-- =============================================================================

DELETE FROM expedicao         WHERE codigo_pedido IN ('abc123','abc789','abc741');
DELETE FROM pedidos           WHERE codigo_pedido IN ('abc123','abc789','abc741');
DELETE FROM compra            WHERE codigo_pedido IN ('abc123','abc789','abc741');
DELETE FROM produtos_em_falta WHERE codigo_pedido IN ('abc999', 'abc888');
DELETE FROM clientes          WHERE codigo_comprador IN ('123','789');
DELETE FROM produtos          WHERE sku IN ('brinq456rio','brinq789rio','roupa123rio', 'limite001rio');
