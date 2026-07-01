namespace CalangoAPI.Domain.Entities.Vendas;

public class Passagem
{
    public Guid Id { get; private set; }
    public Guid ViagemId { get; private set; }
    public Guid ParadaOrigemId { get; private set; }
    public Guid ParadaDestinoId { get; private set; }
    public Guid PassageiroId { get; private set; }
    public int Assento { get; private set; }
    public decimal ValorPago { get; private set; }
    public DateTime DataCompra { get; private set; }

    protected Passagem() { }

    public Passagem(Guid viagemId, Guid paradaOrigemId, Guid paradaDestinoId, Guid passageiroId, int assento, decimal valorPago)
    {
        if (assento <= 0)
            throw new ArgumentException("O assento deve ser maior que zero.");
        if (valorPago < 0)
            throw new ArgumentException("O valor pago não pode ser negativo.");

        Id = Guid.NewGuid();
        ViagemId = viagemId;
        ParadaOrigemId = paradaOrigemId;
        ParadaDestinoId = paradaDestinoId;
        PassageiroId = passageiroId;
        Assento = assento;
        ValorPago = valorPago;
        DataCompra = DateTime.UtcNow;
    }
}