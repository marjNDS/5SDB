using Bazar.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Interfaces.Repositories
{
    public interface IPedidoRepository
    {
        Task AdicionarAsync(Pedido pedido);
        Task AtualizarAsync(Pedido pedido);
        Task<bool> ExistePorOrderIdAsync(string orderId);

        // Este metodo ja deve retornar os pedidos ordenados pelo valor total decrescente,
        // conforme exigido pela regra de negocio do Minimundo.
        Task<IEnumerable<Pedido>> ObterPendentesOrdenadosPorValorAsync();
    }
}
