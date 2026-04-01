# Order Processing — Scripts SQL (PostgreSQL)

Scripts para carga diária de pedidos via CSV no sistema de processamento.

## Estrutura

```
order-processing-pg/
├── 01_staging.sql   # Cria a tabela temporária e carrega o CSV
├── 02_create_tables.sql # Cria as tabelas do sistema (se não existirem)
├── 03_upsert.sql    # UPSERT: insere novos registros ou atualiza existentes
├── 04_cleanup.sql   # Remove a tabela temporária
└── README.md
```

## Ordem de execução

Execute os scripts **na ordem numérica**:

```
01 → 02 → 03 → 04
```

> ⚠️ Os scripts 01, 03 e 04 dependem da tabela `staging` e devem rodar na **mesma sessão** do PostgreSQL.


## Tabelas do sistema

| Tabela | Descrição | Chave |
|---|---|---|
| `clientes` | Dados do comprador | `codigoComprador` |
| `produtos` | Dados do produto | `SKU` |
| `pedidos` | Pedido consolidado com valor total | `codigoPedido` |
| `expedicao` | Endereço de entrega | `codigoPedido` |
| `compra` | Relação pedido ↔ produto | `codigoPedido + SKU` |

## Regra de negócio — valor do pedido

| Situação | Cálculo |
|---|---|
| 1 produto | `(valor × qtd) + frete` |
| N produtos | `(val1×qtd1) + (val2×qtd2) + ... + frete` |

O frete é somado **uma única vez** por pedido.

## Exemplo de resultado

| codigoPedido | valorTotal | Cálculo |
|---|---|---|
| `abc123` | 91,76 | (43,22×1) + (43,22×1) + 5,32 |
| `abc789` | 100,71 | (47,25×2) + 6,21 |
| `abc741` | 48,54 | (43,22×1) + 5,32 |

## Observações

- Em produção, substituir o `INSERT INTO staging VALUES (...)` do script 01 por `COPY` para carregar o arquivo CSV diretamente.
- O script 02 é idempotente: pode ser executado múltiplas vezes sem erro.
- O UPSERT (script 03) atualiza registros existentes e insere novos automaticamente. O `EXCLUDED` referencia os valores que tentaram ser inseridos e geraram conflito.
