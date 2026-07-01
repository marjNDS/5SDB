namespace CalangoAPI.Application.DTOs.Requests;

public record ComprarPassagemRequest(Guid ViagemId, Guid ParadaOrigemId, Guid ParadaDestinoId, Guid PassageiroId, int Assento);