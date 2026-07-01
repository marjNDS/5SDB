using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Domain.Entities.Operacional;

namespace CalangoAPI.Application.Interfaces;

public interface IOperacionalAppService
{
    Task CadastrarViagemAsync(CadastrarViagemRequest request);
    Task<IEnumerable<Viagem>> ListarViagensAsync();
}