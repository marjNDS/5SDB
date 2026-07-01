using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;
using CalangoAPI.Domain.Entities.Vendas;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Domain.Services;

namespace CalangoAPI.Application.Services;

public class VendasAppService : IVendasAppService
{
    private readonly IPassagemRepository _passagemRepository;
    private readonly IViagemRepository _viagemRepository;
    private readonly IOnibusRepository _onibusRepository;
    private readonly IRotaRepository _rotaRepository;
    private readonly CalculadoraPrecoService _calculadoraPrecoService;

    public VendasAppService(
        IPassagemRepository passagemRepository,
        IViagemRepository viagemRepository,
        IOnibusRepository onibusRepository,
        IRotaRepository rotaRepository,
        CalculadoraPrecoService calculadoraPrecoService)
    {
        _passagemRepository = passagemRepository;
        _viagemRepository = viagemRepository;
        _onibusRepository = onibusRepository;
        _rotaRepository = rotaRepository;
        _calculadoraPrecoService = calculadoraPrecoService;
    }

    public async Task<decimal> CalcularPrecoAsync(CalcularPrecoRequest request)
    {
        var viagem = await _viagemRepository.ObterPorIdAsync(request.ViagemId)
            ?? throw new ArgumentException("Viagem não encontrada.");
        var onibus = await _onibusRepository.ObterPorIdAsync(viagem.OnibusId)
            ?? throw new ArgumentException("Autocarro não encontrado.");
        var rota = await _rotaRepository.ObterPorIdAsync(viagem.RotaId)
            ?? throw new ArgumentException("Rota não encontrada.");

        return _calculadoraPrecoService.Calcular(viagem, onibus, rota, request.ParadaOrigemId, request.ParadaDestinoId, DateTime.UtcNow);
    }

    public async Task ComprarPassagemAsync(ComprarPassagemRequest request)
    {
        var viagem = await _viagemRepository.ObterPorIdAsync(request.ViagemId)
            ?? throw new ArgumentException("Viagem não encontrada.");

        var onibus = await _onibusRepository.ObterPorIdAsync(viagem.OnibusId)
            ?? throw new ArgumentException("Autocarro não encontrado.");

        if (request.Assento > onibus.Capacidade)
            throw new ArgumentException($"O autocarro desta viagem possui apenas {onibus.Capacidade} lugares. O assento {request.Assento} e invalido.");

        if (await _passagemRepository.AssentoOcupadoAsync(request.ViagemId, request.Assento))
            throw new ArgumentException("O assento selecionado ja se encontra ocupado.");

        var precoCalculado = await CalcularPrecoAsync(new CalcularPrecoRequest(
            request.ViagemId, request.ParadaOrigemId, request.ParadaDestinoId));

        var passagem = new Passagem(
            request.ViagemId,
            request.ParadaOrigemId,
            request.ParadaDestinoId,
            request.PassageiroId,
            request.Assento,
            precoCalculado
        );

        await _passagemRepository.AdicionarAsync(passagem);
        await _passagemRepository.SalvarAlteracoesAsync();
    }
}