namespace CalangoAPI.Application.DTOs.Requests;

public record CalcularPrecoRequest(Guid ViagemId, Guid ParadaOrigemId, Guid ParadaDestinoId);