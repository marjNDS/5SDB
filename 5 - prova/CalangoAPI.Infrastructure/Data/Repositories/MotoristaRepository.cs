using Microsoft.EntityFrameworkCore;
using CalangoAPI.Domain.Entities.RecursosHumanos;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Infrastructure.Data.Context;

namespace CalangoAPI.Infrastructure.Data.Repositories;

public class MotoristaRepository : IMotoristaRepository
{
    private readonly OnibusDbContext _context;

    public MotoristaRepository(OnibusDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(Motorista motorista)
    {
        await _context.Motoristas.AddAsync(motorista);
    }

    public async Task<Motorista?> ObterPorIdAsync(Guid id)
    {
        return await _context.Motoristas.FindAsync(id);
    }

    public async Task SalvarAlteracoesAsync()
    {
        await _context.SaveChangesAsync();
    }
}