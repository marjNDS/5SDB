namespace CalangoAPI.Application.DTOs.Requests;

public record CadastrarViagemRequest(Guid RotaId, Guid OnibusId, DateTime DataPartida, Guid? MotoristaId = null);