using CalangoAPI.Domain.Entities.Identidade;

namespace CalangoAPI.Domain.Interfaces.Repositories;

public interface IUsuarioRepository
{
    Task AdicionarAsync(Usuario usuario);
    Task<Usuario?> ObterPorEmailAsync(string email);
    Task SalvarAlteracoesAsync();
}
