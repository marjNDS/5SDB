-- ============================================================
-- ETAPA 1: Tabela temporária de staging
-- ============================================================
-- O prefixo # cria uma temp table de sessão no SQL Server.
-- Ela fica no tempdb, não polui o banco principal, e é
-- destruída automaticamente quando a conexão é encerrada.
--
-- Objetivo: receber os dados brutos do CSV antes de qualquer
-- tratamento.
-- ============================================================

CREATE TABLE #staging (
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

-- ============================================================
-- Inserção dos dados do CSV
-- Em produção, substituir por BULK INSERT ou OPENROWSET
-- para carregar o arquivo diretamente, sem INSERT manual.
-- ============================================================
INSERT INTO #staging VALUES
('abc123','2024-03-19','brinq456rio','456','quebra-cabeca',1,43.22,5.32,'samir@gmail.com','123','Samir','Rua Exemplo 1','21212322','RJ','Brasil'),
('abc123','2024-03-19','brinq789rio','789','jogo',         1,43.22,5.32,'samir@gmail.com','123','Samir','Rua Exemplo 1','21212322','RJ','Brasil'),
('abc789','2024-03-20','roupa123rio','123','camisa',       2,47.25,6.21,'teste@gmail.com','789','Fulano','Rua Exemplo 2','14784520','RJ','Brasil'),
('abc741','2024-03-21','brinq789rio','789','jogo',         1,43.22,5.32,'samir@gmail.com','123','Samir','Rua Exemplo 1','21212322','RJ','Brasil');
