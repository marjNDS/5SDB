-- =============================================================================
-- PASSO 6 DE 6: CONSULTA DE PRODUTOS EM FALTA
-- Executar após o passo 4 para visualizar os itens que foram pedidos
-- mas não tinham estoque no momento do processamento.
-- Esses produtos precisam ser providenciados antes do próximo ciclo.
-- =============================================================================

SELECT
    pf.data_registro,
    pf.codigo_pedido,
    pf.sku,
    pf.upc,
    pf.nome_produto,
    pf.quantidade
FROM produtos_em_falta pf
ORDER BY pf.data_registro DESC;
