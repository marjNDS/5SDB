using CalangoAPI.Domain.Entities.Malha;

namespace CalangoAPI.Domain.Interfaces.Repositories;

public interface IRotaRepository
{
    Task AdicionarAsync(Rota rota);
    Task<Rota?> ObterPorIdAsync(Guid id);
    Task<IEnumerable<Rota>> ObterTodasAsync();
    Task SalvarAlteracoesAsync();
}