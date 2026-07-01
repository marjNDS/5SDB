namespace CalangoAPI.Domain.Entities.Operacional;

public class Viagem
{
    public Guid Id { get; private set; }
    public Guid RotaId { get; private set; }
    public Guid OnibusId { get; private set; }
    public DateTime DataPartida { get; private set; }
    public string Status { get; private set; }
    public Guid? MotoristaId { get; private set; }

    protected Viagem()
    {
        Status = null!;
    }

    public Viagem(Guid rotaId, Guid onibusId, DateTime dataPartida)
    {
        if (dataPartida <= DateTime.UtcNow)
            throw new ArgumentException("A data de partida deve ser planeada para o futuro.");

        Id = Guid.NewGuid();
        RotaId = rotaId;
        OnibusId = onibusId;
        DataPartida = dataPartida;
        Status = "Agendada";
    }

    public void AlocarMotorista(Guid motoristaId)
    {
        if (MotoristaId.HasValue)
            throw new ArgumentException("Esta viagem já tem um motorista alocado.");

        MotoristaId = motoristaId;
    }
}