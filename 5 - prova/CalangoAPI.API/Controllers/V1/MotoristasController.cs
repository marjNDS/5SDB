using Microsoft.AspNetCore.Mvc;
using CalangoAPI.Application.DTOs.Requests;
using CalangoAPI.Application.Interfaces;
using CalangoAPI.Domain.Exceptions;

namespace CalangoAPI.API.Controllers.V1;

[ApiController]
[Route("api/v1/[controller]")]
public class MotoristasController : ControllerBase
{
    private readonly IMotoristasAppService _motoristasAppService;

    public MotoristasController(IMotoristasAppService motoristasAppService)
    {
        _motoristasAppService = motoristasAppService;
    }

    [HttpPost]
    public async Task<IActionResult> Cadastrar([FromBody] CadastrarMotoristaRequest request)
    {
        await _motoristasAppService.CadastrarMotoristaAsync(request);
        return Created(string.Empty, new { Mensagem = "Motorista registado com sucesso." });
    }

    [HttpPost("escalas")]
    public async Task<IActionResult> Alocar([FromBody] AlocarMotoristaRequest request)
    {
        try
        {
            await _motoristasAppService.AlocarMotoristaAsync(request);
            return Ok(new { Mensagem = "Motorista alocado à viagem com sucesso." });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Erro = ex.Message });
        }
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> ObterPorId(Guid id)
    {
        try
        {
            var motorista = await _motoristasAppService.ObterMotoristaPorIdAsync(id);
            return Ok(motorista);
        }
        catch (MotoristaNaoEncontradoException ex)
        {
            return NotFound(new { Erro = ex.Message });
        }
    }

    [HttpGet]
    public async Task<IActionResult> ObterTodos()
    {
        var motoristas = await _motoristasAppService.ObterTodosMotoristasAsync();
        return Ok(motoristas);
    }
}