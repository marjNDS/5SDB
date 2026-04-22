-- =============================================================================
-- PROCESSAMENTO DE ATENDIMENTO DE PEDIDOS (CURSOR)
-- Descrição: Percorre os pedidos pendentes, verifica se todos os itens possuem
--            estoque. Se sim, debita o estoque e marca como 'Atendido'.
-- =============================================================================

DO $$
DECLARE
    -- Declara o cursor para buscar apenas os pedidos que ainda não foram atendidos
    cur_pedidos CURSOR FOR 
        SELECT codigo_pedido 
        FROM compra 
        WHERE status = 'Pendente' OR status IS NULL;
        
    v_pedido RECORD;
    v_pode_atender BOOLEAN;
BEGIN
    -- Itera sobre cada pedido retornado pelo cursor
    FOR v_pedido IN cur_pedidos LOOP
        
        -- Verifica se TODOS os itens do pedido atual têm estoque suficiente.
        -- A lógica busca se existe ALGUM item onde a quantidade pedida seja 
        -- maior que o estoque. Se NÃO existir nenhum item assim, v_pode_atender = TRUE.
        SELECT NOT EXISTS (
            SELECT 1
            FROM pedidos pd
            JOIN produtos pr ON pd.sku = pr.sku
            WHERE pd.codigo_pedido = v_pedido.codigo_pedido
              AND pd.quantidade > pr.estoque_atual
        ) INTO v_pode_atender;

        -- Se o pedido puder ser atendido integralmente
        IF v_pode_atender THEN
            
            -- 1. Debita as quantidades compradas do estoque dos produtos
            UPDATE produtos pr
            SET estoque_atual = pr.estoque_atual - pd.quantidade
            FROM pedidos pd
            WHERE pr.sku = pd.sku
              AND pd.codigo_pedido = v_pedido.codigo_pedido;

            -- 2. Atualiza o status do pedido consolidado para 'Atendido'
            UPDATE compra
            SET status = 'Atendido'
            WHERE codigo_pedido = v_pedido.codigo_pedido;

            -- Nota: O PostgreSQL não permite COMMIT dentro de um loop FOR 
            -- em blocos DO anônimos simples. Toda a operação deste bloco 
            -- rodará em uma única transação.
            
        END IF;
        
    END LOOP;
END $$;