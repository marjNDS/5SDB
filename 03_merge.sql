-- ============================================================
-- ETAPA 3: MERGE (UPSERT) nas tabelas do sistema
-- ============================================================
-- O MERGE verifica cada registro da staging contra a tabela
-- de destino:
--   WHEN MATCHED     → registro já existe → ATUALIZA
--   WHEN NOT MATCHED → registro novo      → INSERE
--
-- A ordem respeita as chaves estrangeiras (FK), igual à
-- criação das tabelas:
--   clientes → produtos → pedidos → expedicao → compra
-- ============================================================


-- ------------------------------------------------------------
-- 3.1 MERGE clientes
-- Chave de comparação: codigoComprador
-- DISTINCT garante que clientes com múltiplos pedidos no CSV
-- não sejam processados em duplicata.
-- ------------------------------------------------------------
MERGE INTO clientes AS tgt
USING (
    SELECT DISTINCT codigoComprador, nomeComprador, email
    FROM #staging
) AS src
ON tgt.codigoComprador = src.codigoComprador
WHEN MATCHED THEN
    UPDATE SET
        nomeComprador = src.nomeComprador,
        email         = src.email
WHEN NOT MATCHED THEN
    INSERT (codigoComprador, nomeComprador, email)
    VALUES (src.codigoComprador, src.nomeComprador, src.email);


-- ------------------------------------------------------------
-- 3.2 MERGE produtos
-- Chave de comparação: SKU
-- DISTINCT garante que o mesmo produto (mesmo SKU em pedidos
-- diferentes) não seja processado em duplicata.
-- ------------------------------------------------------------
MERGE INTO produtos AS tgt
USING (
    SELECT DISTINCT SKU, UPC, nomeProduto, valor
    FROM #staging
) AS src
ON tgt.SKU = src.SKU
WHEN MATCHED THEN
    UPDATE SET
        UPC         = src.UPC,
        nomeProduto = src.nomeProduto,
        valor       = src.valor
WHEN NOT MATCHED THEN
    INSERT (SKU, UPC, nomeProduto, valor)
    VALUES (src.SKU, src.UPC, src.nomeProduto, src.valor);


-- ------------------------------------------------------------
-- 3.3 MERGE pedidos
-- Chave de comparação: codigoPedido
--
-- Como um pedido pode ter múltiplas linhas no CSV (um produto
-- por linha), usamos GROUP BY para consolidar:
--   - SUM(valor * qtd): soma o subtotal de cada produto
--   - MAX(frete): pega o frete uma única vez por pedido
--   - Resultado: valorTotal = subtotais + frete
--
-- Exemplo:
--   abc123 → (43.22×1) + (43.22×1) + 5.32 = 91.76
-- ------------------------------------------------------------
MERGE INTO pedidos AS tgt
USING (
    SELECT
        codigoPedido,
        dataPedido,
        codigoComprador,
        SUM(valor * qtd) + MAX(frete) AS valorTotal,
        MAX(frete)                    AS frete
    FROM #staging
    GROUP BY codigoPedido, dataPedido, codigoComprador
) AS src
ON tgt.codigoPedido = src.codigoPedido
WHEN MATCHED THEN
    UPDATE SET
        dataPedido      = src.dataPedido,
        codigoComprador = src.codigoComprador,
        valorTotal      = src.valorTotal,
        frete           = src.frete
WHEN NOT MATCHED THEN
    INSERT (codigoPedido, dataPedido, codigoComprador, valorTotal, frete)
    VALUES (src.codigoPedido, src.dataPedido, src.codigoComprador, src.valorTotal, src.frete);


-- ------------------------------------------------------------
-- 3.4 MERGE expedicao
-- Chave de comparação: codigoPedido
-- DISTINCT garante 1 endereço por pedido, mesmo que o pedido
-- tenha múltiplas linhas no CSV.
-- ------------------------------------------------------------
MERGE INTO expedicao AS tgt
USING (
    SELECT DISTINCT codigoPedido, endereco, CEP, UF, pais
    FROM #staging
) AS src
ON tgt.codigoPedido = src.codigoPedido
WHEN MATCHED THEN
    UPDATE SET
        endereco = src.endereco,
        CEP      = src.CEP,
        UF       = src.UF,
        pais     = src.pais
WHEN NOT MATCHED THEN
    INSERT (codigoPedido, endereco, CEP, UF, pais)
    VALUES (src.codigoPedido, src.endereco, src.CEP, src.UF, src.pais);


-- ------------------------------------------------------------
-- 3.5 MERGE compra
-- Chave de comparação: codigoPedido + SKU (chave composta)
-- Cada linha da staging representa exatamente 1 produto
-- em 1 pedido, então não é necessário DISTINCT ou GROUP BY.
-- ------------------------------------------------------------
MERGE INTO compra AS tgt
USING (
    SELECT codigoPedido, SKU, codigoComprador, qtd
    FROM #staging
) AS src
ON  tgt.codigoPedido = src.codigoPedido
AND tgt.SKU          = src.SKU
WHEN MATCHED THEN
    UPDATE SET
        codigoComprador = src.codigoComprador,
        qtd             = src.qtd
WHEN NOT MATCHED THEN
    INSERT (codigoPedido, SKU, codigoComprador, qtd)
    VALUES (src.codigoPedido, src.SKU, src.codigoComprador, src.qtd);
