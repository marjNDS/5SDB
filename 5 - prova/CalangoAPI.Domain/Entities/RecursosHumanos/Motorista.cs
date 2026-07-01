namespace CalangoAPI.Domain.Entities.RecursosHumanos;

public class Motorista
{
    public Guid Id { get; private set; }
    public string Nome { get; private set; }
    public string CartaConducao { get; private set; }

    protected Motorista()
    {
        Nome = null!;
        CartaConducao = null!;
    }

    public Motorista(string nome, string cartaConducao)
    {
        if (string.IsNullOrWhiteSpace(nome))
            throw new ArgumentException("O nome do motorista é obrigatório.");

        Id = Guid.NewGuid();
        Nome = nome;
        CartaConducao = cartaConducao;
    }
}