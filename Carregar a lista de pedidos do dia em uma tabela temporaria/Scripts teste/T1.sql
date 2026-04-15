-- =============================================================================
-- BLOCO T1: POPULAR O ESTOQUE DE PRODUTOS
-- Cadastra apenas 3 dos 4 SKUs que aparecem nos pedidos de teste.
-- O SKU 'eletro999rio' é propositalmente omitido.
-- =============================================================================

INSERT INTO produtos (sku, upc, nome_produto, valor) VALUES
    ('brinq456rio', '456', 'quebra-cabeca', 43.22),
    ('brinq789rio', '789', 'jogo',          43.22),
    ('roupa123rio', '123', 'camisa',        47.25)
-- Se o produto já existir (re-execução do teste), ignora o conflito
ON CONFLICT (sku) DO NOTHING;