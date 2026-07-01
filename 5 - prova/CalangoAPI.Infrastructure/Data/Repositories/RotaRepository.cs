using Microsoft.EntityFrameworkCore;
using CalangoAPI.Domain.Entities.Malha;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Infrastructure.Data.Context;

namespace CalangoAPI.Infrastructure.Data.Repositories;

public class RotaRepository : IRotaRepository
{
    private readonly OnibusDbContext _context;

    public RotaRepository(OnibusDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(Rota rota)
    {
        await _context.Rotas.AddAsync(rota);
    }

    public async Task<Rota?> ObterPorIdAsync(Guid id)
    {
        return await _context.Rotas
            .Include(r => r.Paradas) // Eager loading da raiz de agregação
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<IEnumerable<Rota>> ObterTodasAsync()
    {
        return await _context.Rotas.Include(r => r.Paradas).ToListAsync();
    }

    public async Task SalvarAlteracoesAsync()
    {
        await _context.SaveChangesAsync();
    }
}