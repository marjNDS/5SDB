namespace Bazar.Application.DTOs;

// Espelha as colunas do arquivo CSV do Marketplace.
// O CsvHelper (que sera usado na infraestrutura) conseguira mapear as colunas diretamente para essas propriedades.
public class CargaPedidoDto
{
    public string OrderId { get; set; }
    public string OrderItemId { get; set; }
    public string PurchaseDate { get; set; }
    public string PaymentsDate { get; set; }
    public string BuyerEmail { get; set; }
    public string BuyerName { get; set; }
    public string Cpf { get; set; }
    public string BuyerPhoneNumber { get; set; }
    public string Sku { get; set; }
    public string ProductName { get; set; }
    public string QuantityPurchased { get; set; }
    public string Currency { get; set; }
    public string ItemPrice { get; set; }
    public string ShipServiceLevel { get; set; }
    public string RecipientName { get; set; }
    public string ShipAddress1 { get; set; }
    public string ShipAddress2 { get; set; }
    public string ShipAddress3 { get; set; }
    public string ShipCity { get; set; }
    public string ShipState { get; set; }
    public string ShipPostalCode { get; set; }
    public string ShipCountry { get; set; }
    public string IossNumber { get; set; }
}