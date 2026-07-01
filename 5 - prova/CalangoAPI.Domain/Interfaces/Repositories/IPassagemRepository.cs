using CalangoAPI.Domain.Entities.Vendas;

namespace CalangoAPI.Domain.Interfaces.Repositories;

public interface IPassagemRepository
{
    Task AdicionarAsync(Passagem passagem);
    Task<bool> AssentoOcupadoAsync(Guid viagemId, int assento);
    Task SalvarAlteracoesAsync();
}