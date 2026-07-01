using Microsoft.EntityFrameworkCore;
using CalangoAPI.Domain.Entities.Frota;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Infrastructure.Data.Context;

namespace CalangoAPI.Infrastructure.Data.Repositories;

public class OnibusRepository : IOnibusRepository
{
    private readonly OnibusDbContext _context;

    public OnibusRepository(OnibusDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(Onibus onibus)
    {
        await _context.Onibus.AddAsync(onibus);
    }

    public async Task<IEnumerable<Onibus>> ObterTodosAsync()
    {
        return await _context.Onibus.ToListAsync();
    }

    public async Task SalvarAlteracoesAsync()
    {
        await _context.SaveChangesAsync();
    }

    public async Task<Onibus?> ObterPorIdAsync(Guid id)
    {
        return await _context.Onibus.FindAsync(id);
    }
}