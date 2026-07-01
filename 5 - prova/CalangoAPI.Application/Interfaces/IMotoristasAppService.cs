using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.DTOs.Responses;

namespace CalangoAPI.Application.Interfaces;

public interface IMotoristasAppService
{
    Task CadastrarMotoristaAsync(CadastrarMotoristaRequest request);
    Task AlocarMotoristaAsync(AlocarMotoristaRequest request);
    Task<MotoristaResponse> ObterMotoristaPorIdAsync(Guid id);
    Task<IEnumerable<MotoristaResponse>> ObterTodosMotoristasAsync();
}