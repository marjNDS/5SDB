using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Bazar.Application.UseCases;
using Bazar.Domain.Services;

namespace Bazar.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class IntegracaoController : ControllerBase
{
    private readonly ImportarPedidosMarketplaceUseCase _importarMarketplaceUseCase;
    private readonly AtendimentoPedidoDomainService _atendimentoService;
    private readonly ImportarAtualizacaoEstoqueFornecedorUseCase _importarFornecedorUseCase;

    public IntegracaoController(
        ImportarPedidosMarketplaceUseCase importarMarketplaceUseCase,
        AtendimentoPedidoDomainService atendimentoService,
        ImportarAtualizacaoEstoqueFornecedorUseCase importarFornecedorUseCase)
    {
        _importarMarketplaceUseCase = importarMarketplaceUseCase;
        _atendimentoService = atendimentoService;
        _importarFornecedorUseCase = importarFornecedorUseCase;
    }

    [HttpPost("processar-marketplace")]
    public async Task<IActionResult> ProcessarMarketplace()
    {
        try
        {
            // O caminho do FTP poderia vir do appsettings ou do corpo da requisição, 
            // mas manteremos fixo conforme o design original.
            await _importarMarketplaceUseCase.ExecutarAsync("ftp://ftp.marketplace.com/pedidos_marketplace.csv");
            await _atendimentoService.ProcessarPedidosPendentesAsync();

            return Ok(new { mensagem = "Processamento do marketplace concluído com sucesso." });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { erro = "Falha ao processar marketplace", detalhe = ex.Message });
        }
    }

    [HttpPost("processar-fornecedor")]
    public async Task<IActionResult> ProcessarFornecedor()
    {
        try
        {
            await _importarFornecedorUseCase.ExecutarAsync("ftp://ftp.fornecedor.com/reposicao_estoque.csv");

            return Ok(new { mensagem = "Atualização de estoque do fornecedor concluída com sucesso." });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { erro = "Falha ao processar arquivo do fornecedor", detalhe = ex.Message });
        }
    }
}