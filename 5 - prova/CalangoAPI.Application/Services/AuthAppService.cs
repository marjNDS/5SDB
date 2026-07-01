using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;
using CalangoAPI.Domain.Entities.Identidade;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Domain.Interfaces.Security;

namespace CalangoAPI.Application.Services;

public class AuthAppService : IAuthAppService
{
    private readonly IUsuarioRepository _usuarioRepository;
    private readonly ITokenService _tokenService;

    public AuthAppService(IUsuarioRepository usuarioRepository, ITokenService tokenService)
    {
        _usuarioRepository = usuarioRepository;
        _tokenService = tokenService;
    }

    public async Task<string> LoginAsync(LoginRequest request)
    {
        var usuario = await _usuarioRepository.ObterPorEmailAsync(request.Email);

        if (usuario == null || !usuario.ValidarSenha(request.Senha))
            throw new ArgumentException("Email ou palavra-passe incorretos.");

        return _tokenService.GerarToken(usuario);
    }

    public async Task RegistrarCompradorAsync(RegistrarRequest request)
    {
        var existente = await _usuarioRepository.ObterPorEmailAsync(request.Email);
        if (existente != null)
            throw new ArgumentException("Este email ja se encontra registado.");

        var usuario = new Usuario(request.Email, request.Senha, "COMPRADOR");

        await _usuarioRepository.AdicionarAsync(usuario);
        await _usuarioRepository.SalvarAlteracoesAsync();
    }
}