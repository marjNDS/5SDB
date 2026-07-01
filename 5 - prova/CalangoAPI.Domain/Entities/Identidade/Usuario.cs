using System.Security.Cryptography;
using System.Text;

namespace CalangoAPI.Domain.Entities.Identidade;

public class Usuario
{
    public Guid Id { get; private set; }
    public string Email { get; private set; }
    public string SenhaHash { get; private set; }
    public string Role { get; private set; }

    protected Usuario()
    {
        Email = null!;
        SenhaHash = null!;
        Role = null!;
    }

    public Usuario(string email, string senhaPlana, string role)
    {
        if (string.IsNullOrWhiteSpace(email)) throw new ArgumentException("O email e obrigatorio.");
        if (string.IsNullOrWhiteSpace(senhaPlana)) throw new ArgumentException("A palavra-passe e obrigatoria.");

        var rolesPermitidas = new[] { "ADM", "COMPRADOR", "VENDEDOR_LOCAL", "MOTORISTA" };
        if (!rolesPermitidas.Contains(role)) throw new ArgumentException("Role invalida.");

        Id = Guid.NewGuid();
        Email = email;
        Role = role;
        SenhaHash = GerarHash(senhaPlana);
    }

    public bool ValidarSenha(string senhaPlana)
    {
        return SenhaHash == GerarHash(senhaPlana);
    }

    private static string GerarHash(string input)
    {
        using var sha256 = SHA256.Create();
        var bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
        return Convert.ToBase64String(bytes);
    }
}