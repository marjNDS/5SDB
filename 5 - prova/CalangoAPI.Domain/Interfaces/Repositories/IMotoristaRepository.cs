using CalangoAPI.Domain.Entities.RecursosHumanos;

namespace CalangoAPI.Domain.Interfaces.Repositories;

public interface IMotoristaRepository
{
    Task AdicionarAsync(Motorista motorista);
    Task<Motorista?> ObterPorIdAsync(Guid id);
    Task<IEnumerable<Motorista>> ObterTodosAsync();
    Task SalvarAlteracoesAsync();
}