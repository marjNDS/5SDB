-- =============================================================================
-- PASSO 4 DE 6: PROCESSAMENTO — DISTRIBUIÇÃO NAS TABELAS DO SISTEMA
-- Executar após o passo 3.
-- Distribui os dados da staging nas tabelas clientes, compra, pedidos e expedicao.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- CLIENTES
-- DISTINCT ON garante um único registro por comprador mesmo que ele apareça
-- em várias linhas da staging (pedido com múltiplos itens).
-- ON CONFLICT atualiza nome e email caso o cliente já exista.
-- -----------------------------------------------------------------------------

INSERT INTO clientes (
    codigo_comprador, nome, email, endereco, cep, uf, pais
)
SELECT DISTINCT ON (codigo_comprador)
    codigo_comprador,
    nome_comprador,
    email,
    endereco,
    cep,
    uf,
    pais
FROM staging_pedidos
ON CONFLICT (codigo_comprador)
DO UPDATE SET
    nome  = EXCLUDED.nome,
    email = EXCLUDED.email;


-- -----------------------------------------------------------------------------
-- COMPRA (TRANSAÇÃO CONSOLIDADA)
-- Calcula o valor total conforme a regra de negócio:
--   1 produto : valor * qtd + frete
--   N produtos: soma(valor * qtd) + frete
-- Usa o valor oficial do cadastro de produtos (p.valor), não o do arquivo.
-- Pedidos já existentes são ignorados (ON CONFLICT DO NOTHING).
-- -----------------------------------------------------------------------------

INSERT INTO compra (
    codigo_pedido, data_pedido, codigo_comprador, frete, valor_total
)
SELECT
    s.codigo_pedido,
    s.data_pedido::DATE,
    s.codigo_comprador,
    -- O frete é o mesmo em todas as linhas do pedido; pegamos o maior valor
    MAX(s.frete_num)                         AS frete,
    -- Valor total = soma de (valor unitário do produto * quantidade) + frete
    SUM(p.valor * s.qtd) + MAX(s.frete_num) AS valor_total
FROM staging_pedidos s
JOIN produtos p ON p.sku = s.sku
GROUP BY
    s.codigo_pedido,
    s.data_pedido,
    s.codigo_comprador
ON CONFLICT (codigo_pedido) DO NOTHING;


-- -----------------------------------------------------------------------------
-- PEDIDOS (ITENS)
-- Uma linha por SKU dentro de cada pedido.
-- NOT EXISTS evita duplicatas caso o script seja reexecutado.
-- -----------------------------------------------------------------------------

INSERT INTO pedidos (
    codigo_pedido, sku, quantidade, valor_unitario
)
SELECT
    s.codigo_pedido,
    s.sku,
    s.qtd,
    p.valor
FROM staging_pedidos s
JOIN produtos p ON p.sku = s.sku
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos pd
    WHERE pd.codigo_pedido = s.codigo_pedido
      AND pd.sku = s.sku
);


-- -----------------------------------------------------------------------------
-- EXPEDIÇÃO
-- Um registro por pedido único (não por item).
-- DISTINCT ON + NOT EXISTS evitam duplicatas.
-- -----------------------------------------------------------------------------

INSERT INTO expedicao (
    codigo_pedido, endereco, cep, uf, pais
)
SELECT DISTINCT ON (s.codigo_pedido)
    s.codigo_pedido,
    s.endereco,
    s.cep,
    s.uf,
    s.pais
FROM staging_pedidos s
JOIN compra c ON c.codigo_pedido = s.codigo_pedido
WHERE NOT EXISTS (
    SELECT 1
    FROM expedicao e
    WHERE e.codigo_pedido = s.codigo_pedido
);
