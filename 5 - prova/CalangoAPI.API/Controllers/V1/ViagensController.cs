using Microsoft.AspNetCore.Mvc;
using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;

namespace CalangoAPI.API.Controllers.V1;

[ApiController]
[Route("api/v1/[controller]")]
public class ViagensController : ControllerBase
{
    private readonly IOperacionalAppService _operacionalAppService;

    public ViagensController(IOperacionalAppService operacionalAppService)
    {
        _operacionalAppService = operacionalAppService;
    }

    [HttpPost]
    public async Task<IActionResult> Cadastrar([FromBody] CadastrarViagemRequest request)
    {
        try
        {
            await _operacionalAppService.CadastrarViagemAsync(request);
            return Created(string.Empty, new { Mensagem = "Viagem planeada com sucesso." });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Erro = ex.Message });
        }
    }

    [HttpGet]
    public async Task<IActionResult> Listar()
    {
        var viagens = await _operacionalAppService.ListarViagensAsync();
        return Ok(viagens);
    }
}