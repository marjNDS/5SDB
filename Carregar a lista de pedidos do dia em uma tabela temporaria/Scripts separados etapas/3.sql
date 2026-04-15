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
FROM 'C:\5sbd\pedidos.txt'
DELIMITER ';'
CSV HEADER;
