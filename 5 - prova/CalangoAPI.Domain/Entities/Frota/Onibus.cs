namespace CalangoAPI.Domain.Entities.Frota;

public class Onibus
{
    public Guid Id { get; private set; }
    public string Placa { get; private set; }
    public int Capacidade { get; private set; }
    public string Tipo { get; private set; }
    public int Quilometragem { get; private set; }
    public string Status { get; private set; }

    protected Onibus() { }

    public Onibus(string placa, int capacidade, string tipo)
    {
        ValidarRegras(capacidade, tipo);

        Id = Guid.NewGuid();
        Placa = placa;
        Capacidade = capacidade;
        Tipo = tipo;
        Quilometragem = 0;
        Status = "Disponível";
    }

    private void ValidarRegras(int capacidade, string tipo)
    {
        var capacidadesPermitidas = new[] { 23, 28, 32, 56 };
        if (!capacidadesPermitidas.Contains(capacidade))
            throw new ArgumentException("A capacidade deve ser 23, 28 ou 32 lugares.");

        var tiposPermitidos = new[] { "leito", "semi-leito", "executivo" };
        if (!tiposPermitidos.Contains(tipo.ToLower()))
            throw new ArgumentException("O tipo de autocarro deve ser leito, semi-leito ou executivo.");
    }
}