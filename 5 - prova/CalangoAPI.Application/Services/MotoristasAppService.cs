using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.DTOs.Responses;
using CalangoAPI.Application.Interfaces;
using CalangoAPI.Domain.Entities.RecursosHumanos;
using CalangoAPI.Domain.Exceptions;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Domain.Services;

namespace CalangoAPI.Application.Services;

public class MotoristasAppService : IMotoristasAppService
{
    private readonly IMotoristaRepository _motoristaRepository;
    private readonly IViagemRepository _viagemRepository;
    private readonly IRotaRepository _rotaRepository;
    private readonly ValidadorEscalaService _validadorEscala;

    public MotoristasAppService(
        IMotoristaRepository motoristaRepository,
        IViagemRepository viagemRepository,
        IRotaRepository rotaRepository,
        ValidadorEscalaService validadorEscala)
    {
        _motoristaRepository = motoristaRepository;
        _viagemRepository = viagemRepository;
        _rotaRepository = rotaRepository;
        _validadorEscala = validadorEscala;
    }

    public async Task CadastrarMotoristaAsync(CadastrarMotoristaRequest request)
    {
        var motorista = new Motorista(request.Nome, request.CartaConducao);
        await _motoristaRepository.AdicionarAsync(motorista);
        await _motoristaRepository.SalvarAlteracoesAsync();
    }

    public async Task AlocarMotoristaAsync(AlocarMotoristaRequest request)
    {
        var viagem = await _viagemRepository.ObterPorIdAsync(request.ViagemId)
            ?? throw new ArgumentException("Viagem não encontrada.");

        var rota = await _rotaRepository.ObterPorIdAsync(viagem.RotaId)
            ?? throw new ArgumentException("Rota não encontrada.");

        var ultimaViagem = await _viagemRepository.ObterUltimaViagemDoMotoristaAsync(request.MotoristaId);

        var paradas = rota.Paradas.OrderBy(p => p.Ordem).ToList();
        var distanciaTotal = paradas.Last().DistanciaInicialKm - paradas.First().DistanciaInicialKm;

        _validadorEscala.ValidarAlocacao(viagem, distanciaTotal, ultimaViagem, DateTime.UtcNow);

        viagem.AlocarMotorista(request.MotoristaId);
        await _viagemRepository.SalvarAlteracoesAsync();
    }

    public async Task<MotoristaResponse> ObterMotoristaPorIdAsync(Guid id)
    {
        var motorista = await _motoristaRepository.ObterPorIdAsync(id)
            ?? throw new MotoristaNaoEncontradoException(id);

        return MotoristaResponse.FromEntity(motorista);
    }

    public async Task<IEnumerable<MotoristaResponse>> ObterTodosMotoristasAsync()
    {
        var motoristas = await _motoristaRepository.ObterTodosAsync();
        return motoristas.Select(MotoristaResponse.FromEntity);
    }
}