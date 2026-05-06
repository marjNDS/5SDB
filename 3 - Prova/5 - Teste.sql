-- =============================================================================
-- SCRIPT DE TESTE E VALIDAÇÃO
-- =============================================================================

-- =============================================================================
-- 1. INJEÇÃO DO CENÁRIO DE ESTOQUE
-- Os produtos recém-carregados da staging possuem estoque inicial igual a zero.
-- É necessário forçar saldos específicos para testar os caminhos da procedure.
-- O Teclado e o Mouse recebem estoque suficiente para faturar o pedido 1001.
-- O Monitor recebe um saldo insuficiente para forçar a retenção do pedido 1002.
-- =============================================================================

UPDATE produtos SET estoque_atual = 10 WHERE sku = 'SKU-TECLADO';
UPDATE produtos SET estoque_atual = 10 WHERE sku = 'SKU-MOUSE';
UPDATE produtos SET estoque_atual = 2  WHERE sku = 'SKU-MONITOR';


-- =============================================================================
-- 2. EXECUÇÃO DA PROCEDURE
-- Aciona o motor de regras de negócio. Os cursores farão a varredura ordenando
-- do maior pedido para o menor e validando a regra do "tudo ou nada".
-- =============================================================================

CALL processar_pedidos_bazar();


-- =============================================================================
-- 3. VERIFICAÇÕES DE AUDITORIA E VALIDAÇÃO
-- Cada bloco abaixo executa uma leitura no banco para atestar o cumprimento
-- das exigências arquiteturais e das regras de negócio.
-- =============================================================================

-- Verificação 1: Status da capa do pedido.
-- O sistema não permite faturamento parcial. 
-- Resultado Esperado:
-- Pedido 1001 -> 'Atendido' (possuía estoque integral).
-- Pedido 1002 -> 'Pendente' (faltou monitor, retendo todo o pedido).
SELECT order_id, status 
FROM pedidos 
ORDER BY order_id;

-- Verificação 2: Saldo físico do catálogo.
-- Apenas os produtos atrelados a pedidos faturados devem sofrer baixa.
-- Resultado Esperado: 
-- SKU-TECLADO -> 8 (iniciou com 10, consumiu 2).
-- SKU-MOUSE   -> 8 (iniciou com 10, consumiu 2).
-- SKU-MONITOR -> 2 (saldo inalterado, pois o pedido foi bloqueado).
SELECT sku, estoque_atual 
FROM produtos 
ORDER BY sku;

-- Verificação 3: Log de movimentação de estoque.
-- A tabela deve registrar as variações de saldo físico antes da alteração final.
-- Resultado Esperado:
-- Registros existentes apenas para SKU-TECLADO e SKU-MOUSE. O monitor não deve
-- possuir registro de movimentação, pois a transação não foi concluída.
SELECT order_id, sku, quantidade_anterior, quantidade_debitada, saldo_final 
FROM movimentacao_estoque 
ORDER BY order_id, sku;

-- Verificação 4: Geração de ordem de compra (fila de reposição).
-- O sistema calcula a necessidade de compra baseada na falta e no lote.
-- Resultado Esperado:
-- Um registro para SKU-MONITOR com status 'Pendente'. 
-- Cálculo da quantidade: O pedido exige 5, o estoque possui 2, gerando falta de 3.
-- Como o lote_reposicao padrão é 10, a quantidade a comprar deve ser arredondada
-- para o próximo múltiplo do lote, totalizando 10 unidades.
SELECT sku, quantidade_comprar, status 
FROM ordens_compra 
ORDER BY sku;