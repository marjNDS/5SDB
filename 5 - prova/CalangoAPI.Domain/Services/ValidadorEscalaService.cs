using CalangoAPI.Domain.Entities.Operacional;

namespace CalangoAPI.Domain.Services;

public class ValidadorEscalaService
{
    public void ValidarAlocacao(Viagem novaViagem, decimal distanciaTotalRota, Viagem? ultimaViagem, DateTime dataAtual)
    {
        // Regra 1: Aviso prévio de 24 horas
        var horasAviso = (novaViagem.DataPartida - dataAtual).TotalHours;
        if (horasAviso < 24)
            throw new ArgumentException("O motorista deve ser avisado com pelo menos 24 horas de antecedência.");

        // Regra 2: Limite de 400km por jornada
        if (distanciaTotalRota > 400)
            throw new ArgumentException("A rota excede o limite legal de 400km por jornada de condução.");

        // Regra 3: Limite de 12 horas de descanso mínimo
        if (ultimaViagem != null)
        {
            // Assumindo uma velocidade média de 60km/h para calcular a duração da última viagem
            var duracaoEstimadaUltimaViagem = distanciaTotalRota / 60m;
            var fimUltimaViagem = ultimaViagem.DataPartida.AddHours((double)duracaoEstimadaUltimaViagem);
            var horasDescanso = (novaViagem.DataPartida - fimUltimaViagem).TotalHours;

            if (horasDescanso < 12)
                throw new ArgumentException($"O motorista não cumpriu as 12 horas de descanso. Horas disponíveis: {Math.Round(horasDescanso, 1)}h.");
        }
    }
}