using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Bazar.Domain.Entities;
using Bazar.Domain.Enums;
using Bazar.Domain.Interfaces.Repositories;
using Bazar.Infrastructure.Data;

namespace Bazar.Infrastructure.Repositories;

public class OrdemCompraRepository : IOrdemCompraRepository
{
    private readonly BazarDbContext _context;

    public OrdemCompraRepository(BazarDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(OrdemCompra ordemCompra)
    {
        await _context.OrdensCompra.AddAsync(ordemCompra);
        await _context.SaveChangesAsync();
    }

    public async Task<bool> ExisteOrdemPendenteParaSkuAsync(string sku)
    {
        return await _context.OrdensCompra
            .AnyAsync(o => o.Sku == sku && o.Status == StatusCompra.Pendente);
    }
}