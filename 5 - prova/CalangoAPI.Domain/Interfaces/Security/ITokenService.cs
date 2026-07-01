using CalangoAPI.Domain.Entities.Identidade;

namespace CalangoAPI.Domain.Interfaces.Security;

public interface ITokenService
{
    string GerarToken(Usuario usuario);
}