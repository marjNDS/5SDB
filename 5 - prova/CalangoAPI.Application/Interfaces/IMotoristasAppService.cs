using CalangoAPI.Application.DTOs.Requests;

namespace CalangoAPI.Application.Interfaces;

public interface IMotoristasAppService
{
    Task CadastrarMotoristaAsync(CadastrarMotoristaRequest request);
    Task AlocarMotoristaAsync(AlocarMotoristaRequest request);
}