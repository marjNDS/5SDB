-- =============================================================================
-- PASSO 2 DE 6: CRIAR STAGING E CARREGAR O ARQUIVO
-- Executar no início de cada carga diária.
-- Cria a tabela temporária do zero e carrega o arquivo pedidos.txt nela.
--
-- !! ATENÇÃO: antes de executar, substitua o caminho do arquivo na linha
--    indicada pelo caminho real do arquivo no seu servidor. !!
-- =============================================================================

-- Recria a staging zerada a cada execução
DROP TABLE IF EXISTS staging_pedidos;

CREATE TEMP TABLE staging_pedidos (
    codigo_pedido    VARCHAR(50),
    data_pedido      VARCHAR(20),   -- recebido como texto; convertido no passo 3
    sku              VARCHAR(100),
    upc              VARCHAR(50),
    nome_produto     VARCHAR(255),
    qtd              INT,
    valor            VARCHAR(20),   -- recebido como texto (ex: "43,22"); convertido no passo 3
    frete            VARCHAR(20),   -- idem
    email            VARCHAR(255),
    codigo_comprador VARCHAR(50),
    nome_comprador   VARCHAR(255),
    endereco         VARCHAR(500),
    cep              VARCHAR(20),
    uf               CHAR(2),
    pais             VARCHAR(100)
);

-- Carrega o arquivo .txt na staging
-- O separador é ";" e a primeira linha (cabeçalho) é ignorada
COPY staging_pedidos (
    codigo_pedido, data_pedido, sku, upc, nome_produto,
    qtd, valor, frete, email, codigo_comprador,
    nome_comprador, endereco, cep, uf, pais
)
FROM '/caminho/para/pedidos.txt'   -- << ALTERE para o caminho real do arquivo
DELIMITER ';'
CSV HEADER;
