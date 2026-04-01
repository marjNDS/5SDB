-- ============================================================
-- ETAPA 3: UPSERT nas tabelas do sistema
-- ============================================================
-- O PostgreSQL não tem MERGE com a mesma sintaxe do SQL Server.
-- Usamos INSERT ... ON CONFLICT, que é o equivalente nativo:
--
--   ON CONFLICT (chave) DO UPDATE SET ...
--     → registro já existe → ATUALIZA
--
--   ON CONFLICT (chave) DO UPDATE SET ...
--     → registro novo → INSERE normalmente
--
-- EXCLUDED é uma tabela virtual que representa os valores
-- que tentaram ser inseridos e geraram o conflito.
-- Ou seja: EXCLUDED.campo = o valor novo vindo da staging.
--
-- Ordem respeita as chaves estrangeiras (FK):
--   clientes → produtos → pedidos → expedicao → compra
-- ============================================================


-- ------------------------------------------------------------
-- 3.1 UPSERT clientes
-- Chave de conflito: codigoComprador
-- DISTINCT garante que clientes com múltiplos pedidos no CSV
-- não sejam processados em duplicata.
-- ------------------------------------------------------------
INSERT INTO clientes (codigoComprador, nomeComprador, email)
SELECT DISTINCT codigoComprador, nomeComprador, email
FROM staging
ON CONFLICT (codigoComprador) DO UPDATE SET
    nomeComprador = EXCLUDED.nomeComprador,
    email         = EXCLUDED.email;


-- ------------------------------------------------------------
-- 3.2 UPSERT produtos
-- Chave de conflito: SKU
-- DISTINCT garante que o mesmo produto (mesmo SKU em pedidos
-- diferentes) não seja processado em duplicata.
-- ------------------------------------------------------------
INSERT INTO produtos (SKU, UPC, nomeProduto, valor)
SELECT DISTINCT SKU, UPC, nomeProduto, valor
FROM staging
ON CONFLICT (SKU) DO UPDATE SET
    UPC         = EXCLUDED.UPC,
    nomeProduto = EXCLUDED.nomeProduto,
    valor       = EXCLUDED.valor;


-- ------------------------------------------------------------
-- 3.3 UPSERT pedidos
-- Chave de conflito: codigoPedido
--
-- Como um pedido pode ter múltiplas linhas no CSV (um produto
-- por linha), usamos GROUP BY para consolidar:
--   - SUM(valor * qtd): soma o subtotal de cada produto
--   - MAX(frete): pega o frete uma única vez por pedido
--
-- Exemplo:
--   abc123 → (43.22×1) + (43.22×1) + 5.32 = 91.76
-- ------------------------------------------------------------
INSERT INTO pedidos (codigoPedido, dataPedido, codigoComprador, valorTotal, frete)
SELECT
    codigoPedido,
    dataPedido,
    codigoComprador,
    SUM(valor * qtd) + MAX(frete) AS valorTotal,
    MAX(frete)                    AS frete
FROM staging
GROUP BY codigoPedido, dataPedido, codigoComprador
ON CONFLICT (codigoPedido) DO UPDATE SET
    dataPedido      = EXCLUDED.dataPedido,
    codigoComprador = EXCLUDED.codigoComprador,
    valorTotal      = EXCLUDED.valorTotal,
    frete           = EXCLUDED.frete;


-- ------------------------------------------------------------
-- 3.4 UPSERT expedicao
-- Chave de conflito: codigoPedido
-- DISTINCT garante 1 endereço por pedido, mesmo que o pedido
-- tenha múltiplas linhas no CSV.
-- ------------------------------------------------------------
INSERT INTO expedicao (codigoPedido, endereco, CEP, UF, pais)
SELECT DISTINCT codigoPedido, endereco, CEP, UF, pais
FROM staging
ON CONFLICT (codigoPedido) DO UPDATE SET
    endereco = EXCLUDED.endereco,
    CEP      = EXCLUDED.CEP,
    UF       = EXCLUDED.UF,
    pais     = EXCLUDED.pais;


-- ------------------------------------------------------------
-- 3.5 UPSERT compra
-- Chave de conflito: codigoPedido + SKU (chave composta)
-- Cada linha da staging representa exatamente 1 produto
-- em 1 pedido, sem necessidade de DISTINCT ou GROUP BY.
-- ------------------------------------------------------------
INSERT INTO compra (codigoPedido, SKU, codigoComprador, qtd)
SELECT codigoPedido, SKU, codigoComprador, qtd
FROM staging
ON CONFLICT (codigoPedido, SKU) DO UPDATE SET
    codigoComprador = EXCLUDED.codigoComprador,
    qtd             = EXCLUDED.qtd;
