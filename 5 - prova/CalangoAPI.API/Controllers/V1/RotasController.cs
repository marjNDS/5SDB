using Microsoft.AspNetCore.Mvc;
using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;

namespace CalangoAPI.API.Controllers.V1;

[ApiController]
[Route("api/v1/[controller]")]
public class RotasController : ControllerBase
{
    private readonly IMalhaAppService _malhaAppService;

    public RotasController(IMalhaAppService malhaAppService)
    {
        _malhaAppService = malhaAppService;
    }

    [HttpPost]
    public async Task<IActionResult> Cadastrar([FromBody] CadastrarRotaRequest request)
    {
        try
        {
            await _malhaAppService.CadastrarRotaAsync(request);
            return Created(string.Empty, new { Mensagem = "Rota e paragens registadas com sucesso." });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Erro = ex.Message });
        }
    }

    [HttpGet]
    public async Task<IActionResult> Listar()
    {
        var rotas = await _malhaAppService.ListarRotasAsync();
        return Ok(rotas);
    }
}