-- =============================================================================
-- FASE 4.1: TABELAS DE APOIO (MOVIMENTAÇÃO E COMPRAS)
-- =============================================================================

-- Tabela para auditar cada saída de estoque
CREATE TABLE IF NOT EXISTS movimentacao_estoque (
    id_movimento         SERIAL PRIMARY KEY,
    order_id             VARCHAR(50) REFERENCES pedidos(order_id),
    sku                  VARCHAR(100) REFERENCES produtos(sku),
    quantidade_anterior  INT NOT NULL,
    quantidade_debitada  INT NOT NULL,
    saldo_final          INT NOT NULL,
    data_registro        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela para registrar o que precisa ser comprado do fornecedor
CREATE TABLE IF NOT EXISTS ordens_compra (
    id_compra            SERIAL PRIMARY KEY,
    sku                  VARCHAR(100) REFERENCES produtos(sku),
    quantidade_comprar   INT NOT NULL,
    status               VARCHAR(20) DEFAULT 'Pendente',
    data_registro        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- FASE 4.2: PROCEDURE DE ATENDIMENTO DE PEDIDOS
-- =============================================================================

CREATE OR REPLACE PROCEDURE processar_pedidos_bazar()
LANGUAGE plpgsql
AS $$
DECLARE
    v_pedido RECORD;
    v_item RECORD;
    v_atende_tudo BOOLEAN;
    v_qtd_falta INT;
    v_qtd_comprar INT;

    -- Cursor 1: Seleciona pedidos pendentes ordenados pelo valor total (maior para menor).
    -- O valor total é calculado multiplicando a quantidade pelo preco_unitario na tabela itens_pedido.
    cur_pedidos CURSOR FOR
        SELECT p.order_id, SUM(ip.quantidade * ip.preco_unitario) AS valor_total
        FROM pedidos p
        JOIN itens_pedido ip ON p.order_id = ip.order_id
        WHERE p.status = 'Pendente'
        GROUP BY p.order_id
        ORDER BY valor_total DESC;

    -- Cursor 2: Seleciona os itens de um pedido específico (recebe o order_id como parâmetro)
    cur_itens CURSOR (p_order_id VARCHAR) FOR
        SELECT ip.sku, ip.quantidade, pr.estoque_atual, pr.lote_reposicao
        FROM itens_pedido ip
        JOIN produtos pr ON ip.sku = pr.sku
        WHERE ip.order_id = p_order_id;

BEGIN
    -- Abre o cursor principal que varre a fila de pedidos
    OPEN cur_pedidos;
    LOOP
        FETCH cur_pedidos INTO v_pedido;
        EXIT WHEN NOT FOUND;

        v_atende_tudo := TRUE;

        -- =====================================================================
        -- PASSO A: Validação do "Tudo ou Nada"
        -- =====================================================================
        OPEN cur_itens(v_pedido.order_id);
        LOOP
            FETCH cur_itens INTO v_item;
            EXIT WHEN NOT FOUND;
            
            -- Se qualquer item pedir mais do que o estoque tem, a flag muda para FALSE
            IF v_item.quantidade > v_item.estoque_atual THEN
                v_atende_tudo := FALSE;
            END IF;
        END LOOP;
        CLOSE cur_itens;

        -- =====================================================================
        -- PASSO B: Execução (Baixar Estoque OU Gerar Compra)
        -- =====================================================================
        IF v_atende_tudo THEN
            
            -- Tem estoque integral. Reabre o cursor para efetivar as baixas.
            OPEN cur_itens(v_pedido.order_id);
            LOOP
                FETCH cur_itens INTO v_item;
                EXIT WHEN NOT FOUND;

                -- 1. Registra a movimentação ANTES de alterar o saldo na tabela produtos
                INSERT INTO movimentacao_estoque (
                    order_id, sku, quantidade_anterior, quantidade_debitada, saldo_final
                ) VALUES (
                    v_pedido.order_id, 
                    v_item.sku, 
                    v_item.estoque_atual, 
                    v_item.quantidade, 
                    (v_item.estoque_atual - v_item.quantidade)
                );

                -- 2. Atualiza o saldo real debitando a quantidade comprada
                UPDATE produtos
                SET estoque_atual = estoque_atual - v_item.quantidade
                WHERE sku = v_item.sku;
            END LOOP;
            CLOSE cur_itens;

            -- 3. Finaliza o pedido marcando como Atendido
            UPDATE pedidos 
            SET status = 'Atendido' 
            WHERE order_id = v_pedido.order_id;

        ELSE
            
            -- Faltou estoque. Reabre o cursor para registrar as faltas.
            OPEN cur_itens(v_pedido.order_id);
            LOOP
                FETCH cur_itens INTO v_item;
                EXIT WHEN NOT FOUND;

                IF v_item.quantidade > v_item.estoque_atual THEN
                    
                    v_qtd_falta := v_item.quantidade - v_item.estoque_atual;
                    
                    -- Calcula quanto comprar arredondando para cima com base no lote de reposição
                    v_qtd_comprar := CEIL(v_qtd_falta::NUMERIC / v_item.lote_reposicao) * v_item.lote_reposicao;

                    -- Insere a ordem de compra apenas se o produto já não estiver na fila de reposição
                    IF NOT EXISTS (
                        SELECT 1 FROM ordens_compra 
                        WHERE sku = v_item.sku AND status = 'Pendente'
                    ) THEN
                        INSERT INTO ordens_compra (sku, quantidade_comprar, status)
                        VALUES (v_item.sku, v_qtd_comprar, 'Pendente');
                    END IF;
                    
                END IF;
            END LOOP;
            CLOSE cur_itens;

        END IF;

    END LOOP;
    CLOSE cur_pedidos;
END;
$$;

