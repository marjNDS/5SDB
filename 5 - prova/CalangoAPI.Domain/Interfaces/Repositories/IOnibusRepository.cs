using CalangoAPI.Domain.Entities.Frota;

namespace CalangoAPI.Domain.Interfaces.Repositories;

public interface IOnibusRepository
{
    Task AdicionarAsync(Onibus onibus);
    Task<IEnumerable<Onibus>> ObterTodosAsync();
    Task SalvarAlteracoesAsync();
    Task<Onibus?> ObterPorIdAsync(Guid id);
}