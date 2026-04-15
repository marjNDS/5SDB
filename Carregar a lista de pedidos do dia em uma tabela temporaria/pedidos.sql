-- =============================================================================
-- SISTEMA DE PROCESSAMENTO DE PEDIDOS
-- Banco de dados: PostgreSQL
-- Descrição: Carrega pedidos do dia a partir de um arquivo .txt (staging),
--            distribui os dados nas tabelas do sistema e aplica as regras
--            de negócio definidas.
-- =============================================================================


-- =============================================================================
-- BLOCO 1: CRIAÇÃO DAS TABELAS DO SISTEMA
-- Executar apenas uma vez. Se as tabelas já existirem, este bloco é ignorado
-- graças ao IF NOT EXISTS.
-- =============================================================================

-- Clientes: um registro por comprador único
CREATE TABLE IF NOT EXISTS clientes (
    codigo_comprador  VARCHAR(50)  PRIMARY KEY,
    nome              VARCHAR(255) NOT NULL,
    email             VARCHAR(255) NOT NULL,
    endereco          VARCHAR(500),
    cep               VARCHAR(20),
    uf                CHAR(2),
    pais              VARCHAR(100)
);

-- Produtos: um registro por SKU (chave interna da empresa)
CREATE TABLE IF NOT EXISTS produtos (
    sku           VARCHAR(100) PRIMARY KEY,
    upc           VARCHAR(50),
    nome_produto  VARCHAR(255) NOT NULL,
    valor         NUMERIC(10, 2) NOT NULL
);

-- Compra: representa a transação financeira consolidada de um pedido inteiro.
-- Um pedido pode ter N itens; a compra registra o total + frete.
CREATE TABLE IF NOT EXISTS compra (
    codigo_pedido  VARCHAR(50)  PRIMARY KEY,
    data_pedido    DATE         NOT NULL,
    codigo_comprador VARCHAR(50) NOT NULL REFERENCES clientes(codigo_comprador),
    frete          NUMERIC(10, 2) NOT NULL,
    valor_total    NUMERIC(10, 2) NOT NULL  -- calculado: soma(valor*qtd) + frete
);

-- Pedidos: cada linha representa um item dentro de uma compra.
-- Um mesmo codigo_pedido pode aparecer N vezes aqui (um por SKU).
CREATE TABLE IF NOT EXISTS pedidos (
    id             SERIAL       PRIMARY KEY,
    codigo_pedido  VARCHAR(50)  NOT NULL REFERENCES compra(codigo_pedido),
    sku            VARCHAR(100) NOT NULL REFERENCES produtos(sku),
    quantidade     INT          NOT NULL,
    valor_unitario NUMERIC(10, 2) NOT NULL
);

-- Expedição: dados de entrega por pedido (um por compra)
CREATE TABLE IF NOT EXISTS expedicao (
    id             SERIAL      PRIMARY KEY,
    codigo_pedido  VARCHAR(50) NOT NULL REFERENCES compra(codigo_pedido),
    endereco       VARCHAR(500),
    cep            VARCHAR(20),
    uf             CHAR(2),
    pais           VARCHAR(100)
);

-- Produtos em falta: SKUs que foram pedidos mas não constam na tabela produtos.
-- Esses registros precisam ser providenciados antes de processar o pedido.
CREATE TABLE IF NOT EXISTS produtos_em_falta (
    id             SERIAL      PRIMARY KEY,
    codigo_pedido  VARCHAR(50),
    sku            VARCHAR(100),
    upc            VARCHAR(50),
    nome_produto   VARCHAR(255),
    quantidade     INT,
    data_registro  TIMESTAMP   DEFAULT NOW()
);


-- =============================================================================
-- BLOCO 2: TABELA TEMPORÁRIA DE STAGING
-- Criada a cada execução para receber o arquivo bruto sem transformação.
-- O uso de TEMP garante que ela seja descartada ao final da sessão.
-- =============================================================================

DROP TABLE IF EXISTS staging_pedidos;

CREATE TEMP TABLE staging_pedidos (
    codigo_pedido    VARCHAR(50),
    data_pedido      VARCHAR(20),   -- recebido como texto; convertido depois
    sku              VARCHAR(100),
    upc              VARCHAR(50),
    nome_produto     VARCHAR(255),
    qtd              INT,
    valor            VARCHAR(20),   -- recebido como texto (ex: "43,22"); convertido depois
    frete            VARCHAR(20),   -- idem
    email            VARCHAR(255),
    codigo_comprador VARCHAR(50),
    nome_comprador   VARCHAR(255),
    endereco         VARCHAR(500),
    cep              VARCHAR(20),
    uf               CHAR(2),
    pais             VARCHAR(100)
);


-- =============================================================================
-- BLOCO 3: CARGA DO ARQUIVO PARA A TABELA DE STAGING
-- O comando COPY lê o arquivo .txt com separador ";" e ignora o cabeçalho.
-- Ajuste o caminho do arquivo conforme o ambiente.
-- Os valores monetários usam vírgula como separador decimal (padrão BR),
-- então são carregados como texto e convertidos na sequência.
-- =============================================================================

COPY staging_pedidos (
    codigo_pedido, data_pedido, sku, upc, nome_produto,
    qtd, valor, frete, email, codigo_comprador,
    nome_comprador, endereco, cep, uf, pais
)
FROM '/caminho/para/pedidos.txt'   -- << ALTERE para o caminho real do arquivo
DELIMITER ';'
CSV HEADER;


-- =============================================================================
-- BLOCO 4: NORMALIZAÇÃO DOS VALORES MONETÁRIOS NA STAGING
-- Substitui vírgula por ponto para que o PostgreSQL consiga converter
-- os campos de valor e frete para NUMERIC.
-- =============================================================================

-- Cria colunas auxiliares já com o tipo correto
ALTER TABLE staging_pedidos
    ADD COLUMN IF NOT EXISTS valor_num NUMERIC(10,2),
    ADD COLUMN IF NOT EXISTS frete_num NUMERIC(10,2);

-- Converte substituindo vírgula por ponto antes do cast
UPDATE staging_pedidos
SET
    valor_num = REPLACE(valor, ',', '.')::NUMERIC(10,2),
    frete_num = REPLACE(frete, ',', '.')::NUMERIC(10,2);


-- =============================================================================
-- BLOCO 5: SEPARAR PRODUTOS SEM ESTOQUE
-- Antes de processar qualquer tabela do sistema, identificamos os itens cujo
-- SKU não existe em 'produtos'. Esses itens vão para 'produtos_em_falta' e
-- são EXCLUÍDOS da staging para não contaminar o restante do processamento.
-- =============================================================================

-- Insere na tabela de falta os itens cujo SKU não existe em produtos
INSERT INTO produtos_em_falta (
    codigo_pedido, sku, upc, nome_produto, quantidade, data_registro
)
SELECT
    s.codigo_pedido,
    s.sku,
    s.upc,
    s.nome_produto,
    s.qtd,
    NOW()
FROM staging_pedidos s
-- LEFT JOIN com produtos: onde p.sku é NULL, o SKU não existe no estoque
LEFT JOIN produtos p ON p.sku = s.sku
WHERE p.sku IS NULL;

-- Remove da staging os itens sem estoque para que não sejam processados
DELETE FROM staging_pedidos
WHERE sku NOT IN (SELECT sku FROM produtos);


-- =============================================================================
-- BLOCO 6: INSERIR / ATUALIZAR CLIENTES
-- Usa INSERT ... ON CONFLICT para evitar duplicatas: se o cliente já existe,
-- atualiza os dados cadastrais com as informações mais recentes do arquivo.
-- =============================================================================

INSERT INTO clientes (
    codigo_comprador, nome, email, endereco, cep, uf, pais
)
-- DISTINCT ON garante um único registro por comprador mesmo que ele
-- apareça em várias linhas da staging (vários itens no mesmo pedido)
SELECT DISTINCT ON (codigo_comprador)
    codigo_comprador,
    nome_comprador,
    email,
    endereco,
    cep,
    uf,
    pais
FROM staging_pedidos
ON CONFLICT (codigo_comprador)
DO UPDATE SET
    nome  = EXCLUDED.nome,
    email = EXCLUDED.email;


-- =============================================================================
-- BLOCO 7: INSERIR COMPRA (TRANSAÇÃO CONSOLIDADA)
-- Calcula o valor total de cada pedido conforme a regra de negócio:
--   - 1 produto : valor * qtd + frete
--   - N produtos: soma(valor * qtd) + frete
-- A regra é a mesma expressão em ambos os casos; a distinção no enunciado
-- é apenas conceitual — matematicamente SUM(valor*qtd)+frete cobre os dois.
-- =============================================================================

INSERT INTO compra (
    codigo_pedido, data_pedido, codigo_comprador, frete, valor_total
)
SELECT
    s.codigo_pedido,
    s.data_pedido::DATE,
    s.codigo_comprador,
    -- O frete é o mesmo em todas as linhas do pedido; pegamos o primeiro valor
    MAX(s.frete_num)                            AS frete,
    -- Valor total = soma de (valor unitário do produto * quantidade) + frete
    SUM(p.valor * s.qtd) + MAX(s.frete_num)    AS valor_total
FROM staging_pedidos s
-- JOIN com produtos para garantir que usamos o valor oficial do cadastro,
-- não o valor informado no arquivo (que pode estar desatualizado)
JOIN produtos p ON p.sku = s.sku
GROUP BY
    s.codigo_pedido,
    s.data_pedido,
    s.codigo_comprador
ON CONFLICT (codigo_pedido) DO NOTHING;  -- pedido já existente é ignorado


-- =============================================================================
-- BLOCO 8: INSERIR ITENS EM PEDIDOS
-- Uma linha por SKU dentro de cada pedido.
-- Evita duplicatas verificando se o par (codigo_pedido, sku) já existe.
-- =============================================================================

INSERT INTO pedidos (
    codigo_pedido, sku, quantidade, valor_unitario
)
SELECT
    s.codigo_pedido,
    s.sku,
    s.qtd,
    p.valor   -- valor oficial do cadastro de produtos
FROM staging_pedidos s
JOIN produtos p ON p.sku = s.sku
-- Não insere se esse item já foi registrado para este pedido
WHERE NOT EXISTS (
    SELECT 1
    FROM pedidos pd
    WHERE pd.codigo_pedido = s.codigo_pedido
      AND pd.sku = s.sku
);


-- =============================================================================
-- BLOCO 9: INSERIR EXPEDIÇÃO
-- Um registro por pedido único (não por item).
-- Evita duplicatas verificando se o codigo_pedido já existe em expedicao.
-- =============================================================================

INSERT INTO expedicao (
    codigo_pedido, endereco, cep, uf, pais
)
SELECT DISTINCT ON (s.codigo_pedido)
    s.codigo_pedido,
    s.endereco,
    s.cep,
    s.uf,
    s.pais
FROM staging_pedidos s
JOIN compra c ON c.codigo_pedido = s.codigo_pedido
WHERE NOT EXISTS (
    SELECT 1
    FROM expedicao e
    WHERE e.codigo_pedido = s.codigo_pedido
);


-- =============================================================================
-- BLOCO 10: RELATÓRIO FINAL — PEDIDOS DO DIA (DO MAIS CARO AO MAIS BARATO)
-- Exibe os pedidos processados hoje com dados do cliente e da expedição,
-- ordenados de forma decrescente pelo valor total da compra.
-- =============================================================================

SELECT
    c.codigo_pedido,
    c.data_pedido,
    cl.nome                         AS nome_cliente,
    cl.email,
    e.endereco,
    e.cep,
    e.uf,
    c.frete,
    c.valor_total
FROM compra c
-- Traz os dados do cliente responsável pela compra
JOIN clientes cl  ON cl.codigo_comprador = c.codigo_comprador
-- Traz os dados de entrega do pedido
JOIN expedicao e  ON e.codigo_pedido     = c.codigo_pedido
-- Filtra apenas os pedidos do dia atual
WHERE c.data_pedido = CURRENT_DATE
ORDER BY c.valor_total DESC;
