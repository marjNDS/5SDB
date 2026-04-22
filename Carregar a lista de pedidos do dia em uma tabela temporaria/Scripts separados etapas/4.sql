-- =============================================================================
-- BLOCO 4: NORMALIZAÇÃO DOS VALORES MONETÁRIOS NA STAGING
-- Substitui vírgula por ponto para que o PostgreSQL consiga converter
-- os campos de valor e frete para NUMERIC.
-- =============================================================================

-- Cria colunas auxiliares já com o tipo correto
ALTER TABLE staging_pedidos
    ADD COLUMN IF NOT EXISTS valor_num NUMERIC(10,2),
    ADD COLUMN IF NOT EXISTS frete_num NUMERIC(10,2);

-- Converte substituindo vírgula por ponto antes do cast
UPDATE staging_pedidos
SET
    valor_num = REPLACE(valor, ',', '.')::NUMERIC(10,2),
    frete_num = REPLACE(frete, ',', '.')::NUMERIC(10,2);