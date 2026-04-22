-- =============================================================================
-- BLOCO T1: POPULAR O ESTOQUE DE PRODUTOS
-- Cadastra 4 SKUs que aparecem nos pedidos de teste, incluindo o saldo de estoque.
-- O SKU 'eletro999rio' é propositalmente omitido.
-- O SKU 'limite001rio' recebe apenas 2 unidades para testar a falta de saldo.
-- =============================================================================

INSERT INTO produtos (sku, upc, nome_produto, valor, estoque_atual) VALUES
    ('brinq456rio', '456', 'quebra-cabeca',  43.22, 50),
    ('brinq789rio', '789', 'jogo',           43.22, 50),
    ('roupa123rio', '123', 'camisa',         47.25, 50),
    ('limite001rio', '001', 'produto-limite', 10.00, 2)
-- Se o produto já existir (re-execução do teste), ignora o conflito
ON CONFLICT (sku) DO NOTHING;