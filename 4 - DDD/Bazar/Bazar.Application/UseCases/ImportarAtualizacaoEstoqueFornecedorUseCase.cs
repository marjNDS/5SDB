using System.Linq;
using System.Threading.Tasks;
using Bazar.Application.Interfaces;
using Bazar.Application.DTOs;
using Bazar.Domain.Entities;
using Bazar.Domain.Interfaces.Repositories;

namespace Bazar.Application.UseCases;

// Orquestra o recebimento de mercadorias fisicas e a atualizacao do sistema de inventario.
public class ImportarAtualizacaoEstoqueFornecedorUseCase
{
    private readonly IFtpService _ftpService;
    private readonly ICsvParserService _csvParser;
    private readonly IProdutoRepository _produtoRepository;
    private readonly IMovimentacaoEstoqueRepository _movimentacaoRepository;

    public ImportarAtualizacaoEstoqueFornecedorUseCase(
        IFtpService ftpService,
        ICsvParserService csvParser,
        IProdutoRepository produtoRepository,
        IMovimentacaoEstoqueRepository movimentacaoRepository)
    {
        _ftpService = ftpService;
        _csvParser = csvParser;
        _produtoRepository = produtoRepository;
        _movimentacaoRepository = movimentacaoRepository;
    }

    public async Task ExecutarAsync(string caminhoFtp)
    {
        // 1. Baixa o arquivo do fornecedor e converte para a memoria
        using var stream = await _ftpService.BaixarArquivoAsync(caminhoFtp);
        var linhasCsv = _csvParser.LerCsv<CargaFornecedorDto>(stream).ToList();

        // 2. Itera sobre os itens entregues pelo fornecedor
        foreach (var linha in linhasCsv)
        {
            if (string.IsNullOrWhiteSpace(linha.Sku) || linha.QuantidadeEntregue <= 0)
                continue;

            var produto = await _produtoRepository.ObterPorSkuAsync(linha.Sku);

            if (produto != null)
            {
                int estoqueAnterior = produto.EstoqueAtual;

                // 3. Atualiza o saldo usando o metodo de dominio para garantir integridade
                produto.CreditarEstoque(linha.QuantidadeEntregue);
                await _produtoRepository.AtualizarAsync(produto);

                // 4. Registra a auditoria de entrada usando o Factory Method da entidade
                var movimentacao = MovimentacaoEstoque.CriarEntrada(
                    produto.Sku,
                    estoqueAnterior,
                    linha.QuantidadeEntregue
                );

                await _movimentacaoRepository.AdicionarAsync(movimentacao);
            }
        }
    }
}