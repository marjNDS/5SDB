namespace CalangoAPI.Domain.Entities.Malha;

public class Rota
{
    public Guid Id { get; private set; }
    public string Nome { get; private set; }
    public List<int> PontosDeVendaIds { get; private set; }

    private readonly List<Parada> _paradas = new();
    public IReadOnlyCollection<Parada> Paradas => _paradas.AsReadOnly();

    protected Rota() { }

    public Rota(string nome, List<int> pontosDeVendaIds)
    {
        if (string.IsNullOrWhiteSpace(nome))
            throw new ArgumentException("O nome da rota não pode estar vazio.");

        Id = Guid.NewGuid();
        Nome = nome;
        PontosDeVendaIds = pontosDeVendaIds ?? new List<int>();
    }

    public void AdicionarParadas(IEnumerable<Parada> novasParadas)
    {
        var paradasOrdenadas = novasParadas.OrderBy(p => p.Ordem).ToList();

        if (paradasOrdenadas.Count < 2)
            throw new ArgumentException("Uma rota deve ter pelo menos duas paradas (origem e destino).");

        decimal ultimaDistancia = -1;
        foreach (var parada in paradasOrdenadas)
        {
            if (parada.DistanciaInicialKm <= ultimaDistancia)
                throw new ArgumentException($"A distância da paragem '{parada.NomeLocalidade}' deve ser superior à paragem anterior.");

            ultimaDistancia = parada.DistanciaInicialKm;
            _paradas.Add(parada);
        }
    }
}