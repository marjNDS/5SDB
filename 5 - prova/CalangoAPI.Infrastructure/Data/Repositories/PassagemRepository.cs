using Microsoft.EntityFrameworkCore;
using CalangoAPI.Domain.Entities.Vendas;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Infrastructure.Data.Context;

namespace CalangoAPI.Infrastructure.Data.Repositories;

public class PassagemRepository : IPassagemRepository
{
    private readonly OnibusDbContext _context;

    public PassagemRepository(OnibusDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(Passagem passagem)
    {
        await _context.Passagens.AddAsync(passagem);
    }

    public async Task<bool> AssentoOcupadoAsync(Guid viagemId, int assento)
    {
        return await _context.Passagens
            .AnyAsync(p => p.ViagemId == viagemId && p.Assento == assento);
    }

    public async Task SalvarAlteracoesAsync()
    {
        await _context.SaveChangesAsync();
    }
}