using System;
using System.Threading.Tasks;
using Bazar.Domain.Interfaces.Repositories;
using Bazar.Domain.Entities;

namespace Bazar.Domain.Services;

// Nota: Domain Services encapsulam regras de negocio que nao pertencem naturalmente a uma unica entidade.

public class AtendimentoPedidoDomainService
{
    private readonly IPedidoRepository _pedidoRepository;
    private readonly IProdutoRepository _produtoRepository;
    private readonly IMovimentacaoEstoqueRepository _movimentacaoRepository;
    private readonly IOrdemCompraRepository _ordemCompraRepository;

    public AtendimentoPedidoDomainService(
        IPedidoRepository pedidoRepository,
        IProdutoRepository produtoRepository,
        IMovimentacaoEstoqueRepository movimentacaoRepository,
        IOrdemCompraRepository ordemCompraRepository)
    {
        _pedidoRepository = pedidoRepository;
        _produtoRepository = produtoRepository;
        _movimentacaoRepository = movimentacaoRepository;
        _ordemCompraRepository = ordemCompraRepository;
    }

    public async Task ProcessarPedidosPendentesAsync()
    {
        // 1. Busca os pedidos pendentes ja ordenados do maior valor para o menor
        var pedidosPendentes = await _pedidoRepository.ObterPendentesOrdenadosPorValorAsync();

        foreach (var pedido in pedidosPendentes)
        {
            bool atendeTudo = true;

            // PASSO A: Validacao do estoque antes de realizar qualquer alteracao
            foreach (var item in pedido.Itens)
            {
                var produto = await _produtoRepository.ObterPorSkuAsync(item.Sku);

                if (produto == null || item.Quantidade > produto.EstoqueAtual)
                {
                    atendeTudo = false;
                    break;
                }
            }

            // PASSO B: Execucao da regra de negocio
            if (atendeTudo)
            {
                // Processa o atendimento integral
                foreach (var item in pedido.Itens)
                {
                    var produto = await _produtoRepository.ObterPorSkuAsync(item.Sku);
                    int estoqueAnterior = produto.EstoqueAtual;

                    // A entidade Produto valida e altera seu proprio estado
                    produto.DebitarEstoque(item.Quantidade);
                    await _produtoRepository.AtualizarAsync(produto);

                    // Registra a auditoria
                    var movimentacao = MovimentacaoEstoque.CriarSaida(
                        pedido.OrderId, item.Sku, estoqueAnterior, item.Quantidade);

                    await _movimentacaoRepository.AdicionarAsync(movimentacao);
                }

                pedido.MarcarComoAtendido();
                await _pedidoRepository.AtualizarAsync(pedido);
            }
            else
            {
                // Se faltou algo, varre os itens novamente para gerar as compras necessarias
                foreach (var item in pedido.Itens)
                {
                    var produto = await _produtoRepository.ObterPorSkuAsync(item.Sku);

                    if (produto != null && item.Quantidade > produto.EstoqueAtual)
                    {
                        int qtdFalta = item.Quantidade - produto.EstoqueAtual;

                        // Calculo de arredondamento para cima baseado no lote de reposicao
                        int qtdComprar = (int)Math.Ceiling((double)qtdFalta / produto.LoteReposicao) * produto.LoteReposicao;

                        // Verifica se ja existe um pedido de compra pendente para nao duplicar pedidos ao fornecedor
                        bool jaExisteCompra = await _ordemCompraRepository.ExisteOrdemPendenteParaSkuAsync(produto.Sku);

                        if (!jaExisteCompra)
                        {
                            var ordemCompra = new OrdemCompra(produto.Sku, qtdComprar);
                            await _ordemCompraRepository.AdicionarAsync(ordemCompra);
                        }
                    }
                }
            }
        }
    }
}