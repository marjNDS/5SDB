using CalangoAPI.Application.DTOs.Requests;

namespace CalangoAPI.Application.Interfaces;

public interface IVendasAppService
{
    Task<decimal> CalcularPrecoAsync(CalcularPrecoRequest request);
    Task ComprarPassagemAsync(ComprarPassagemRequest request);
}