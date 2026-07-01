using System.Threading.Tasks;
using Bazar.Domain.Entities;
using Bazar.Domain.Interfaces.Repositories;
using Bazar.Infrastructure.Data;

namespace Bazar.Infrastructure.Repositories;

public class MovimentacaoEstoqueRepository : IMovimentacaoEstoqueRepository
{
    private readonly BazarDbContext _context;

    public MovimentacaoEstoqueRepository(BazarDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(MovimentacaoEstoque movimentacao)
    {
        await _context.MovimentacoesEstoque.AddAsync(movimentacao);
        await _context.SaveChangesAsync();
    }
}