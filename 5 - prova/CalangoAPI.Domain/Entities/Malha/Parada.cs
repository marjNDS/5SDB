namespace CalangoAPI.Domain.Entities.Malha;

public class Parada
{
    public Guid Id { get; private set; }
    public string NomeLocalidade { get; private set; }
    public int Ordem { get; private set; }
    public decimal DistanciaInicialKm { get; private set; }

    // Propriedade de navegação para o EF Core
    public Guid RotaId { get; private set; }

    protected Parada() { } // Construtor para o EF Core

    public Parada(string nomeLocalidade, int ordem, decimal distanciaInicialKm)
    {
        Id = Guid.NewGuid();
        NomeLocalidade = nomeLocalidade;
        Ordem = ordem;
        DistanciaInicialKm = distanciaInicialKm;
    }
}