using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;
using CalangoAPI.Domain.Entities.Malha;
using CalangoAPI.Domain.Interfaces.Repositories;

namespace CalangoAPI.Application.Services;

public class MalhaAppService : IMalhaAppService
{
    private readonly IRotaRepository _repository;

    public MalhaAppService(IRotaRepository repository)
    {
        _repository = repository;
    }

    public async Task CadastrarRotaAsync(CadastrarRotaRequest request)
    {
        var rota = new Rota(request.Nome, request.PontosDeVendaIds);

        var paradas = request.Paradas.Select(p =>
            new Parada(p.NomeLocalidade, p.Ordem, p.DistanciaInicialKm)).ToList();

        rota.AdicionarParadas(paradas);

        await _repository.AdicionarAsync(rota);
        await _repository.SalvarAlteracoesAsync();
    }

    public async Task<IEnumerable<Rota>> ListarRotasAsync()
    {
        return await _repository.ObterTodasAsync();
    }
}