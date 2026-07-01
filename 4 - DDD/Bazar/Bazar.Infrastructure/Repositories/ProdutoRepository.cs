using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Bazar.Domain.Entities;
using Bazar.Domain.Interfaces.Repositories;
using Bazar.Infrastructure.Data;

namespace Bazar.Infrastructure.Repositories;

public class ProdutoRepository : IProdutoRepository
{
    private readonly BazarDbContext _context;

    public ProdutoRepository(BazarDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(Produto produto)
    {
        await _context.Produtos.AddAsync(produto);
        await _context.SaveChangesAsync();
    }

    public async Task AtualizarAsync(Produto produto)
    {
        _context.Produtos.Update(produto);
        await _context.SaveChangesAsync();
    }

    public async Task<Produto> ObterPorSkuAsync(string sku)
    {
        return await _context.Produtos.FirstOrDefaultAsync(p => p.Sku == sku);
    }

    public async Task<bool> ExistePorSkuAsync(string sku)
    {
        return await _context.Produtos.AnyAsync(p => p.Sku == sku);
    }
}