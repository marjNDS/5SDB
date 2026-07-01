using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;
using CalangoAPI.Domain.Entities.Operacional;
using CalangoAPI.Domain.Interfaces.Repositories;

namespace CalangoAPI.Application.Services;

public class OperacionalAppService : IOperacionalAppService
{
    private readonly IViagemRepository _viagemRepository;

    public OperacionalAppService(IViagemRepository viagemRepository)
    {
        _viagemRepository = viagemRepository;
    }

    public async Task CadastrarViagemAsync(CadastrarViagemRequest request)
    {
        var viagem = new Viagem(request.RotaId, request.OnibusId, request.DataPartida);

        await _viagemRepository.AdicionarAsync(viagem);
        await _viagemRepository.SalvarAlteracoesAsync();
    }

    public async Task<IEnumerable<Viagem>> ListarViagensAsync()
    {
        return await _viagemRepository.ObterTodasAsync();
    }
}
