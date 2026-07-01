using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Domain.Entities.Malha;

namespace CalangoAPI.Application.Interfaces;

public interface IMalhaAppService
{
    Task CadastrarRotaAsync(CadastrarRotaRequest request);
    Task<IEnumerable<Rota>> ListarRotasAsync();
}