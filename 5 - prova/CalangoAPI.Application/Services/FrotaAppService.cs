using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;
using CalangoAPI.Domain.Entities.Frota;
using CalangoAPI.Domain.Interfaces.Repositories;

namespace CalangoAPI.Application.Services;

public class FrotaAppService : IFrotaAppService
{
    private readonly IOnibusRepository _repository;

    public FrotaAppService(IOnibusRepository repository)
    {
        _repository = repository;
    }

    public async Task CadastrarOnibusAsync(CadastrarOnibusRequest request)
    {
        var onibus = new Onibus(request.Placa, request.Capacidade, request.Tipo);
        await _repository.AdicionarAsync(onibus);
        await _repository.SalvarAlteracoesAsync();
    }

    public async Task<IEnumerable<Onibus>> ListarOnibusAsync()
    {
        return await _repository.ObterTodosAsync();
    }
}