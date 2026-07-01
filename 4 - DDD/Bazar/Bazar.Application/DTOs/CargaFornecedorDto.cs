namespace Bazar.Application.DTOs;

// Espelha as colunas do arquivo CSV enviado pelo fornecedor com a reposicao de estoque.
public class CargaFornecedorDto
{
    public string Sku { get; set; }
    public int QuantidadeEntregue { get; set; }
}