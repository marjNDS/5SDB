using CalangoAPI.Domain.Entities.Operacional;

namespace CalangoAPI.Domain.Interfaces.Repositories;

public interface IViagemRepository
{
    Task AdicionarAsync(Viagem viagem);
    Task<IEnumerable<Viagem>> ObterTodasAsync();
    Task SalvarAlteracoesAsync();
    Task<Viagem?> ObterPorIdAsync(Guid id);
    Task<Viagem?> ObterUltimaViagemDoMotoristaAsync(Guid motoristaId);
}