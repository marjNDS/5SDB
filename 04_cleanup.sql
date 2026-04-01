-- ============================================================
-- ETAPA 4: Limpeza da tabela temporária
-- ============================================================
-- A tabela temporária é destruída automaticamente ao encerrar
-- a sessão, mas removê-la explicitamente é boa prática:
--   - Libera memória imediatamente
--   - Deixa claro que o processamento foi concluído
--   - Evita conflito se o script for reexecutado na mesma sessão
-- ============================================================

DROP TABLE IF EXISTS staging;
