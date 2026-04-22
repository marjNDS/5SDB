-- =============================================================================
-- BLOCO T3: EXECUTAR O PROCESSAMENTO (replica os blocos do script principal)
-- =============================================================================

-- Produtos sem cadastro OU sem saldo suficiente -> produtos_em_falta
INSERT INTO produtos_em_falta (
    codigo_pedido, sku, upc, nome_produto, quantidade, data_registro
)
SELECT
    s.codigo_pedido, s.sku, s.upc, s.nome_produto, s.qtd, NOW()
FROM staging_pedidos s
LEFT JOIN produtos p ON p.sku = s.sku
WHERE p.sku IS NULL OR s.qtd > p.estoque_atual;

-- Remove da staging os itens sem cadastro ou saldo insuficiente
DELETE FROM staging_pedidos
WHERE sku NOT IN (SELECT sku FROM produtos)
   OR qtd > (SELECT estoque_atual FROM produtos WHERE sku = staging_pedidos.sku);

-- Clientes
INSERT INTO clientes (codigo_comprador, nome, email, endereco, cep, uf, pais)
SELECT DISTINCT ON (codigo_comprador)
    codigo_comprador, nome_comprador, email, endereco, cep, uf, pais
FROM staging_pedidos
ON CONFLICT (codigo_comprador) DO UPDATE SET
    nome  = EXCLUDED.nome,
    email = EXCLUDED.email;

-- Compra (valor total calculado)
INSERT INTO compra (codigo_pedido, data_pedido, codigo_comprador, frete, valor_total)
SELECT
    s.codigo_pedido,
    s.data_pedido::DATE,
    s.codigo_comprador,
    MAX(s.frete_num),
    SUM(p.valor * s.qtd) + MAX(s.frete_num)
FROM staging_pedidos s
JOIN produtos p ON p.sku = s.sku
GROUP BY s.codigo_pedido, s.data_pedido, s.codigo_comprador
ON CONFLICT (codigo_pedido) DO NOTHING;

-- Itens do pedido
INSERT INTO pedidos (codigo_pedido, sku, quantidade, valor_unitario)
SELECT s.codigo_pedido, s.sku, s.qtd, p.valor
FROM staging_pedidos s
JOIN produtos p ON p.sku = s.sku
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos pd
    WHERE pd.codigo_pedido = s.codigo_pedido AND pd.sku = s.sku
);

-- Expedição
INSERT INTO expedicao (codigo_pedido, endereco, cep, uf, pais)
SELECT DISTINCT ON (s.codigo_pedido)
    s.codigo_pedido, s.endereco, s.cep, s.uf, s.pais
FROM staging_pedidos s
JOIN compra c ON c.codigo_pedido = s.codigo_pedido
WHERE NOT EXISTS (
    SELECT 1 FROM expedicao e WHERE e.codigo_pedido = s.codigo_pedido
);