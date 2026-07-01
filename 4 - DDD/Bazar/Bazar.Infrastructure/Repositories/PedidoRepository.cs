using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Bazar.Domain.Entities;
using Bazar.Domain.Enums;
using Bazar.Domain.Interfaces.Repositories;
using Bazar.Infrastructure.Data;

namespace Bazar.Infrastructure.Repositories;

public class PedidoRepository : IPedidoRepository
{
    private readonly BazarDbContext _context;

    public PedidoRepository(BazarDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(Pedido pedido)
    {
        await _context.Pedidos.AddAsync(pedido);
        await _context.SaveChangesAsync();
    }

    public async Task AtualizarAsync(Pedido pedido)
    {
        _context.Pedidos.Update(pedido);
        await _context.SaveChangesAsync();
    }

    public async Task<bool> ExistePorOrderIdAsync(string orderId)
    {
        return await _context.Pedidos.AnyAsync(p => p.OrderId == orderId);
    }

    public async Task<IEnumerable<Pedido>> ObterPendentesOrdenadosPorValorAsync()
    {
        // O Include carrega a lista privada de itens. 
        // O OrderByDescending aplica a regra de negocio diretamente na consulta.
        return await _context.Pedidos
            .Include(p => p.Itens)
            .Where(p => p.Status == StatusPedido.Pendente)
            .OrderByDescending(p => p.Itens.Sum(i => i.Quantidade * i.PrecoUnitario))
            .ToListAsync();
    }
}