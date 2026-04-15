-- =============================================================================
-- BLOCO T4: VERIFICAÇÕES
-- Cada verificação tem um resultado esperado documentado.
-- Compare a saída real com o esperado para validar cada exigência.
-- =============================================================================

-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 1 — Exigência [1]: dados chegaram nas tabelas corretas?
-- Esperado: 2 clientes, 3 produtos, 3 compras, 4 itens de pedido, 3 expedições
-- ----------------------------------------------------------------------------
SELECT 'clientes'        AS tabela, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'produtos',                  COUNT(*)           FROM produtos
UNION ALL
SELECT 'compra',                    COUNT(*)           FROM compra
UNION ALL
SELECT 'pedidos (itens)',           COUNT(*)           FROM pedidos
UNION ALL
SELECT 'expedicao',                 COUNT(*)           FROM expedicao;


-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 2 — Exigência [2]: cálculo do valor total dos pedidos
--
-- Esperado:
--   abc123 → (43,22 * 1) + (43,22 * 1) + 5,32  = 91,76  (N produtos)
--   abc789 → (47,25 * 2)               + 6,21   = 100,71 (1 produto, qtd=2)
--   abc741 → (43,22 * 1)               + 5,32   = 48,54  (1 produto)
-- ----------------------------------------------------------------------------
SELECT
    codigo_pedido,
    frete,
    valor_total,
    CASE
        WHEN codigo_pedido = 'abc123' AND valor_total = 91.76  THEN 'OK'
        WHEN codigo_pedido = 'abc789' AND valor_total = 100.71 THEN 'OK'
        WHEN codigo_pedido = 'abc741' AND valor_total = 48.54  THEN 'OK'
        ELSE 'FALHOU'
    END AS resultado
FROM compra
WHERE codigo_pedido IN ('abc123', 'abc789', 'abc741')
ORDER BY codigo_pedido;


-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 3 — Exigência [3]: produto sem estoque foi isolado?
--
-- Esperado: 1 registro com sku = 'eletro999rio' e codigo_pedido = 'abc999'
--           O pedido abc999 NÃO deve aparecer em compra nem em pedidos.
-- ----------------------------------------------------------------------------
SELECT 'produtos_em_falta' AS verificacao, codigo_pedido, sku, nome_produto, quantidade
FROM produtos_em_falta
WHERE sku = 'eletro999rio';

-- Confirma que abc999 não vazou para as tabelas do sistema
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'OK — abc999 ausente em compra'
         ELSE 'FALHOU — abc999 presente em compra'
    END AS resultado
FROM compra WHERE codigo_pedido = 'abc999';

SELECT
    CASE WHEN COUNT(*) = 0 THEN 'OK — abc999 ausente em pedidos'
         ELSE 'FALHOU — abc999 presente em pedidos'
    END AS resultado
FROM pedidos WHERE codigo_pedido = 'abc999';


-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 4 — Exigência [4]: pedidos ordenados do mais caro ao mais barato
--
-- Esperado (ordem): abc789 (100,71) → abc123 (91,76) → abc741 (48,54)
-- ----------------------------------------------------------------------------
SELECT
    c.codigo_pedido,
    cl.nome       AS cliente,
    c.valor_total,
    ROW_NUMBER() OVER (ORDER BY c.valor_total DESC) AS posicao,
    CASE ROW_NUMBER() OVER (ORDER BY c.valor_total DESC)
        WHEN 1 THEN CASE WHEN c.codigo_pedido = 'abc789' THEN 'OK' ELSE 'FALHOU' END
        WHEN 2 THEN CASE WHEN c.codigo_pedido = 'abc123' THEN 'OK' ELSE 'FALHOU' END
        WHEN 3 THEN CASE WHEN c.codigo_pedido = 'abc741' THEN 'OK' ELSE 'FALHOU' END
    END AS resultado
FROM compra c
JOIN clientes cl ON cl.codigo_comprador = c.codigo_comprador
ORDER BY c.valor_total DESC;