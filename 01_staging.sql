-- ============================================================
-- ETAPA 1: Tabela temporária de staging
-- ============================================================
-- Estratégia em duas etapas:
--
--   1. raw_staging: recebe tudo como texto via COPY.
--      Necessário porque o arquivo usa vírgula como separador
--      decimal (ex: 43,22), e o PostgreSQL espera ponto (43.22).
--      Se tentássemos carregar direto em colunas DECIMAL, o COPY
--      falharia com erro de conversão.
--
--   2. staging: recebe os dados do raw_staging já com os tipos
--      corretos, após substituir vírgula por ponto nos campos
--      numéricos com REPLACE(..., ',', '.').
-- ============================================================


-- ------------------------------------------------------------
-- Passo 1: tabela intermediária com tudo como texto
-- ------------------------------------------------------------
CREATE TEMPORARY TABLE raw_staging (
    codigoPedido    TEXT,
    dataPedido      TEXT,
    SKU             TEXT,
    UPC             TEXT,
    nomeProduto     TEXT,
    qtd             TEXT,
    valor           TEXT,
    frete           TEXT,
    email           TEXT,
    codigoComprador TEXT,
    nomeComprador   TEXT,
    endereco        TEXT,
    CEP             TEXT,
    UF              TEXT,
    pais            TEXT
);

-- ------------------------------------------------------------
-- Passo 2: carregar o arquivo CSV no raw_staging
--
-- Ajuste o caminho '/caminho/para/pedidos.txt' para o local
-- real do arquivo no seu servidor PostgreSQL.
--
-- DELIMITER ';' → separador de colunas do arquivo
-- CSV HEADER    → ignora a primeira linha (cabeçalho)
-- ------------------------------------------------------------
COPY raw_staging
FROM '/caminho/para/pedidos.txt'
DELIMITER ';'
CSV HEADER;


-- ------------------------------------------------------------
-- Passo 3: tabela staging com os tipos corretos
-- ------------------------------------------------------------
CREATE TEMPORARY TABLE staging (
    codigoPedido    VARCHAR(50),
    dataPedido      DATE,
    SKU             VARCHAR(50),
    UPC             VARCHAR(50),
    nomeProduto     VARCHAR(100),
    qtd             INT,
    valor           DECIMAL(10,2),
    frete           DECIMAL(10,2),
    email           VARCHAR(100),
    codigoComprador VARCHAR(50),
    nomeComprador   VARCHAR(100),
    endereco        VARCHAR(200),
    CEP             VARCHAR(20),
    UF              VARCHAR(5),
    pais            VARCHAR(50)
);

-- ------------------------------------------------------------
-- Passo 4: mover os dados do raw_staging para a staging,
-- convertendo os tipos no processo.
--
-- REPLACE(valor, ',', '.') → troca vírgula por ponto antes
-- de converter para DECIMAL (ex: '43,22' → '43.22' → 43.22)
-- ------------------------------------------------------------
INSERT INTO staging
SELECT
    codigoPedido,
    dataPedido::DATE,
    SKU,
    UPC,
    nomeProduto,
    qtd::INT,
    REPLACE(valor, ',', '.')::DECIMAL(10,2),
    REPLACE(frete, ',', '.')::DECIMAL(10,2),
    email,
    codigoComprador,
    nomeComprador,
    endereco,
    CEP,
    UF,
    pais
FROM raw_staging;

-- ------------------------------------------------------------
-- Passo 5: descartar o raw_staging — já não é mais necessário
-- ------------------------------------------------------------
DROP TABLE raw_staging;