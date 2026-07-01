using CalangoAPI.Domain.Entities.Frota;
using CalangoAPI.Domain.Entities.Malha;
using CalangoAPI.Domain.Entities.Operacional;

namespace CalangoAPI.Domain.Services;

public class CalculadoraPrecoService
{
    private const decimal PrecoBasePorKm = 0.50m;

    public decimal Calcular(Viagem viagem, Onibus onibus, Rota rota, Guid paradaOrigemId, Guid paradaDestinoId, DateTime dataCompra)
    {
        var origem = rota.Paradas.FirstOrDefault(p => p.Id == paradaOrigemId)
            ?? throw new ArgumentException("Paragem de origem invalida.");
        var destino = rota.Paradas.FirstOrDefault(p => p.Id == paradaDestinoId)
            ?? throw new ArgumentException("Paragem de destino invalida.");

        if (origem.DistanciaInicialKm >= destino.DistanciaInicialKm)
            throw new ArgumentException("A paragem de destino deve ser posterior a de origem.");

        decimal distanciaKm = destino.DistanciaInicialKm - origem.DistanciaInicialKm;

        decimal fatorTipo = onibus.Tipo.ToLower() switch
        {
            "leito" => 1.5m,
            "semi-leito" => 1.2m,
            "executivo" => 1.0m,
            _ => 1.0m
        };

        decimal precoCalculado = distanciaKm * PrecoBasePorKm * fatorTipo;

        var primeiraParada = rota.Paradas.OrderBy(p => p.Ordem).First();
        var ultimaParada = rota.Paradas.OrderBy(p => p.Ordem).Last();
        if (origem.Id == primeiraParada.Id && destino.Id == ultimaParada.Id)
        {
            precoCalculado *= 0.90m;
        }

        if ((viagem.DataPartida - dataCompra).TotalDays >= 7)
        {
            precoCalculado *= 0.95m;
        }

        return Math.Round(precoCalculado, 2);
    }
}