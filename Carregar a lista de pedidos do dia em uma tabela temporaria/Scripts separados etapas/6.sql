-- =============================================================================
-- BLOCO 10: RELATÓRIO FINAL — PEDIDOS DO DIA (DO MAIS CARO AO MAIS BARATO)
-- Exibe os pedidos processados hoje com dados do cliente e da expedição,
-- ordenados de forma decrescente pelo valor total da compra.
-- =============================================================================

SELECT
    c.codigo_pedido,
    c.data_pedido,
    cl.nome                         AS nome_cliente,
    cl.email,
    e.endereco,
    e.cep,
    e.uf,
    c.frete,
    c.valor_total
FROM compra c
-- Traz os dados do cliente responsável pela compra
JOIN clientes cl  ON cl.codigo_comprador = c.codigo_comprador
-- Traz os dados de entrega do pedido
JOIN expedicao e  ON e.codigo_pedido     = c.codigo_pedido
-- Filtra apenas os pedidos do dia atual
WHERE c.data_pedido = CURRENT_DATE
ORDER BY c.valor_total DESC;