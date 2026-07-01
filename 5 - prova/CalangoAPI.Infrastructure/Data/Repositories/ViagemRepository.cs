using Microsoft.EntityFrameworkCore;
using CalangoAPI.Domain.Entities.Operacional;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Infrastructure.Data.Context;

namespace CalangoAPI.Infrastructure.Data.Repositories;

public class ViagemRepository : IViagemRepository
{
    private readonly OnibusDbContext _context;

    public ViagemRepository(OnibusDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(Viagem viagem)
    {
        await _context.Viagens.AddAsync(viagem);
    }

    public async Task<IEnumerable<Viagem>> ObterTodasAsync()
    {
        return await _context.Viagens.ToListAsync();
    }

    public async Task SalvarAlteracoesAsync()
    {
        await _context.SaveChangesAsync();
    }

    public async Task<Viagem?> ObterPorIdAsync(Guid id)
    {
        return await _context.Viagens.FindAsync(id);
    }

    public async Task<Viagem?> ObterUltimaViagemDoMotoristaAsync(Guid motoristaId)
    {
        return await _context.Viagens
            .Where(v => v.MotoristaId == motoristaId)
            .OrderByDescending(v => v.DataPartida)
            .FirstOrDefaultAsync();
    }
}