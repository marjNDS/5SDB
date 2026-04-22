-- =============================================================================
-- BLOCO T4: VERIFICAÇÕES
-- Compare a saída real com o esperado para validar cada exigência.
-- =============================================================================

-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 1 — Dados chegaram nas tabelas corretas?
-- Esperado: 2 clientes, 4 produtos, 3 compras, 4 itens de pedido, 3 expedições
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
-- VERIFICAÇÃO 2 — Cálculo do valor total dos pedidos processados com sucesso
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
-- VERIFICAÇÃO 3 — Itens sem estoque ou saldo insuficiente foram isolados?
-- Esperado: 2 registros (abc999 e abc888) na tabela produtos_em_falta.
--           Ambos NÃO devem aparecer nas tabelas de sistema (compra e pedidos).
-- ----------------------------------------------------------------------------
SELECT 'produtos_em_falta' AS verificacao, codigo_pedido, sku, nome_produto, quantidade
FROM produtos_em_falta
WHERE codigo_pedido IN ('abc999', 'abc888')
ORDER BY codigo_pedido;

-- Confirma que os itens barrados não vazaram
SELECT
    CASE WHEN COUNT(*) = 0 THEN 'OK — abc888 e abc999 ausentes em compra'
         ELSE 'FALHOU — vazamento para a tabela compra'
    END AS resultado_compra
FROM compra WHERE codigo_pedido IN ('abc999', 'abc888');

SELECT
    CASE WHEN COUNT(*) = 0 THEN 'OK — abc888 e abc999 ausentes em pedidos'
         ELSE 'FALHOU — vazamento para a tabela pedidos'
    END AS resultado_pedidos
FROM pedidos WHERE codigo_pedido IN ('abc999', 'abc888');

-- ----------------------------------------------------------------------------
-- VERIFICAÇÃO 4 — Pedidos ordenados do mais caro ao mais barato
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