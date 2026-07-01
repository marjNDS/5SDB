namespace CalangoAPI.Application.DTOs.Responses;

public record MotoristaResponse(Guid Id, string Nome, string CartaConducao)
{
    public static MotoristaResponse FromEntity(Domain.Entities.RecursosHumanos.Motorista motorista)
    {
        return new MotoristaResponse(motorista.Id, motorista.Nome, motorista.CartaConducao);
    }
}