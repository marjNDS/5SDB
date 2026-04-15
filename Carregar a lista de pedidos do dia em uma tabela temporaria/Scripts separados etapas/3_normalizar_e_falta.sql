-- =============================================================================
-- PASSO 3 DE 6: NORMALIZAÇÃO E SEPARAÇÃO DE PRODUTOS SEM ESTOQUE
-- Executar logo após o passo 2.
--
-- Parte A: converte os campos de valor e frete de texto (vírgula) para NUMERIC.
-- Parte B: isola os itens cujo SKU não existe em produtos e os remove da staging.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- PARTE A: NORMALIZAÇÃO DOS VALORES MONETÁRIOS
-- Cria colunas auxiliares com o tipo correto e converte vírgula em ponto
-- para que o PostgreSQL consiga operar sobre os valores.
-- -----------------------------------------------------------------------------

ALTER TABLE staging_pedidos
    ADD COLUMN IF NOT EXISTS valor_num NUMERIC(10,2),
    ADD COLUMN IF NOT EXISTS frete_num NUMERIC(10,2);

UPDATE staging_pedidos
SET
    valor_num = REPLACE(valor, ',', '.')::NUMERIC(10,2),
    frete_num = REPLACE(frete, ',', '.')::NUMERIC(10,2);


-- -----------------------------------------------------------------------------
-- PARTE B: SEPARAR PRODUTOS SEM ESTOQUE
-- LEFT JOIN com produtos: onde p.sku é NULL, o SKU não existe no cadastro.
-- Esses itens vão para produtos_em_falta e são removidos da staging para
-- não contaminar o restante do processamento.
-- -----------------------------------------------------------------------------

INSERT INTO produtos_em_falta (
    codigo_pedido, sku, upc, nome_produto, quantidade, data_registro
)
SELECT
    s.codigo_pedido,
    s.sku,
    s.upc,
    s.nome_produto,
    s.qtd,
    NOW()
FROM staging_pedidos s
LEFT JOIN produtos p ON p.sku = s.sku
WHERE p.sku IS NULL;

-- Remove da staging os itens sem estoque
DELETE FROM staging_pedidos
WHERE sku NOT IN (SELECT sku FROM produtos);
