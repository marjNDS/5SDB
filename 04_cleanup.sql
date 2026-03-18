-- ============================================================
-- ETAPA 4: Limpeza da tabela temporária
-- ============================================================
-- A #staging é destruída automaticamente ao fechar a sessão,
-- mas removê-la explicitamente é boa prática:
--   - Libera espaço no tempdb imediatamente
--   - Deixa claro no código que o processamento foi concluído
--   - Evita conflito se o script for reexecutado na mesma sessão
-- ============================================================

DROP TABLE #staging;
