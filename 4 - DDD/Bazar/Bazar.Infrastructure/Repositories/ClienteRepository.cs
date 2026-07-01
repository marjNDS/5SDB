using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Bazar.Domain.Entities;
using Bazar.Domain.Interfaces.Repositories;
using Bazar.Infrastructure.Data;

namespace Bazar.Infrastructure.Repositories;

public class ClienteRepository : IClienteRepository
{
    private readonly BazarDbContext _context;

    public ClienteRepository(BazarDbContext context)
    {
        _context = context;
    }

    public async Task AdicionarAsync(Cliente cliente)
    {
        await _context.Clientes.AddAsync(cliente);
        await _context.SaveChangesAsync();
    }

    public async Task<bool> ExistePorCpfAsync(string cpf)
    {
        return await _context.Clientes.AnyAsync(c => c.Cpf == cpf);
    }
}