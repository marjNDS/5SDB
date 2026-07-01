using Microsoft.AspNetCore.Mvc;
using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;

namespace CalangoAPI.API.Controllers.V1;

[ApiController]
[Route("api/v1/[controller]")]
public class OnibusController : ControllerBase
{
    private readonly IFrotaAppService _frotaAppService;

    public OnibusController(IFrotaAppService frotaAppService)
    {
        _frotaAppService = frotaAppService;
    }

    [HttpPost]
    public async Task<IActionResult> Cadastrar([FromBody] CadastrarOnibusRequest request)
    {
        try
        {
            await _frotaAppService.CadastrarOnibusAsync(request);
            return Created(string.Empty, new { Mensagem = "Autocarro registado com sucesso." });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Erro = ex.Message });
        }
    }

    [HttpGet]
    public async Task<IActionResult> Listar()
    {
        var frota = await _frotaAppService.ListarOnibusAsync();
        return Ok(frota);
    }
}