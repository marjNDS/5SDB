using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Domain.Entities.Frota;

namespace CalangoAPI.Application.Interfaces;

public interface IFrotaAppService
{
    Task CadastrarOnibusAsync(CadastrarOnibusRequest request);
    Task<IEnumerable<Onibus>> ListarOnibusAsync();
}