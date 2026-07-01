using CalangoAPI.Application.DTOs.Requests;

namespace CalangoAPI.Application.Interfaces;

public interface IAuthAppService
{
    Task<string> LoginAsync(LoginRequest request);
    Task RegistrarCompradorAsync(RegistrarRequest request);
}