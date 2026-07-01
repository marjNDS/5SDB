using Microsoft.AspNetCore.Mvc;
using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;

namespace CalangoAPI.API.Controllers.V1;

[ApiController]
[Route("api/v1/[controller]")]
public class PassagensController : ControllerBase
{
    private readonly IVendasAppService _vendasAppService;

    public PassagensController(IVendasAppService vendasAppService)
    {
        _vendasAppService = vendasAppService;
    }

    [HttpPost("calcular-preco")]
    public async Task<IActionResult> CalcularPreco([FromBody] CalcularPrecoRequest request)
    {
        try
        {
            var preco = await _vendasAppService.CalcularPrecoAsync(request);
            return Ok(new { ValorPago = preco });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Erro = ex.Message });
        }
    }

    [HttpPost("comprar")]
    public async Task<IActionResult> Comprar([FromBody] ComprarPassagemRequest request)
    {
        try
        {
            await _vendasAppService.ComprarPassagemAsync(request);
            return Created(string.Empty, new { Mensagem = "Passagem adquirida com sucesso." });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Erro = ex.Message });
        }
    }
}