namespace CalangoAPI.Application.DTOs.Requests;

public record ParadaRequest(string NomeLocalidade, int Ordem, decimal DistanciaInicialKm);

public record CadastrarRotaRequest(string Nome, List<int> PontosDeVendaIds, List<ParadaRequest> Paradas);