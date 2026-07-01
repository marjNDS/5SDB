using System;
using System.Linq;
using System.Threading.Tasks;
using Bazar.Application.Interfaces;
using Bazar.Application.DTOs;
using Bazar.Domain.Entities;
using Bazar.Domain.Interfaces.Repositories;
using Bazar.Domain.ValueObjects;

namespace Bazar.Application.UseCases;

// Orquestra a carga inicial dos dados desnormalizados do CSV para o modelo relacional e orientado a objetos do Dominio.
public class ImportarPedidosMarketplaceUseCase
{
    private readonly IFtpService _ftpService;
    private readonly ICsvParserService _csvParser;
    private readonly IClienteRepository _clienteRepository;
    private readonly IProdutoRepository _produtoRepository;
    private readonly IPedidoRepository _pedidoRepository;

    public ImportarPedidosMarketplaceUseCase(
        IFtpService ftpService,
        ICsvParserService csvParser,
        IClienteRepository clienteRepository,
        IProdutoRepository produtoRepository,
        IPedidoRepository pedidoRepository)
    {
        _ftpService = ftpService;
        _csvParser = csvParser;
        _clienteRepository = clienteRepository;
        _produtoRepository = produtoRepository;
        _pedidoRepository = pedidoRepository;
    }

    public async Task ExecutarAsync(string caminhoFtp)
    {
        // 1. Baixa e le o arquivo
        using var stream = await _ftpService.BaixarArquivoAsync(caminhoFtp);
        var linhasCsv = _csvParser.LerCsv<CargaPedidoDto>(stream).ToList();

        // 2. Agrupa as linhas pelo CPF para inserir clientes unicos
        var clientesUnicos = linhasCsv.GroupBy(x => x.Cpf).Select(g => g.First());
        foreach (var linha in clientesUnicos)
        {
            if (string.IsNullOrWhiteSpace(linha.Cpf)) continue;

            bool clienteExiste = await _clienteRepository.ExistePorCpfAsync(linha.Cpf);
            if (!clienteExiste)
            {
                var endereco = new Endereco(
                    $"{linha.ShipAddress1} {linha.ShipAddress2} {linha.ShipAddress3}".Trim(),
                    linha.ShipCity,
                    linha.ShipState,
                    linha.ShipPostalCode,
                    linha.ShipCountry
                );

                var cliente = new Cliente(linha.Cpf, linha.BuyerName, linha.BuyerEmail, linha.BuyerPhoneNumber, endereco);
                await _clienteRepository.AdicionarAsync(cliente);
            }
        }

        // 3. Agrupa as linhas pelo SKU para inserir produtos unicos
        var produtosUnicos = linhasCsv.GroupBy(x => x.Sku).Select(g => g.First());
        foreach (var linha in produtosUnicos)
        {
            if (string.IsNullOrWhiteSpace(linha.Sku)) continue;

            bool produtoExiste = await _produtoRepository.ExistePorSkuAsync(linha.Sku);
            if (!produtoExiste)
            {
                // A regra define um lote de reposicao padrao de 10, ajustavel futuramente
                var produto = new Produto(linha.Sku, null, linha.ProductName, 10);
                await _produtoRepository.AdicionarAsync(produto);
            }
        }

        // 4. Agrupa as linhas pelo OrderId para montar os Pedidos e seus Itens
        var pedidosAgrupados = linhasCsv.GroupBy(x => x.OrderId);
        foreach (var grupoPedido in pedidosAgrupados)
        {
            var primeiraLinha = grupoPedido.First();

            if (string.IsNullOrWhiteSpace(primeiraLinha.OrderId)) continue;

            bool pedidoExiste = await _pedidoRepository.ExistePorOrderIdAsync(primeiraLinha.OrderId);
            if (!pedidoExiste)
            {
                // Conversao de datas extraidas do CSV
                DateTime.TryParse(primeiraLinha.PurchaseDate, out DateTime dataCompra);
                DateTime.TryParse(primeiraLinha.PaymentsDate, out DateTime dataPagamento);

                var pedido = new Pedido(
                    primeiraLinha.OrderId,
                    primeiraLinha.Cpf,
                    dataCompra,
                    dataPagamento,
                    primeiraLinha.ShipServiceLevel
                );

                // Adiciona todos os itens que pertencem a este pedido
                foreach (var linhaItem in grupoPedido)
                {
                    int.TryParse(linhaItem.QuantityPurchased, out int quantidade);

                    // Tratamento para valor monetario que pode vir com virgula ou ponto
                    string precoLimpo = linhaItem.ItemPrice?.Replace(",", ".");
                    decimal.TryParse(precoLimpo, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal precoUnitario);

                    var item = new ItemPedido(
                        linhaItem.OrderItemId,
                        linhaItem.Sku,
                        quantidade,
                        linhaItem.Currency,
                        precoUnitario
                    );

                    pedido.AdicionarItem(item);
                }

                await _pedidoRepository.AdicionarAsync(pedido);
            }
        }
    }
}