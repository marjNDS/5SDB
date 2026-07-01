using Bazar.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Reflection.Emit;

namespace Bazar.Infrastructure.Data;

public class BazarDbContext : DbContext
{
    public DbSet<Cliente> Clientes { get; set; }
    public DbSet<Produto> Produtos { get; set; }
    public DbSet<Pedido> Pedidos { get; set; }
    public DbSet<ItemPedido> ItensPedido { get; set; }
    public DbSet<MovimentacaoEstoque> MovimentacoesEstoque { get; set; }
    public DbSet<OrdemCompra> OrdensCompra { get; set; }

    public BazarDbContext(DbContextOptions<BazarDbContext> options) : base(options) { }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Esta instrucao varre o projeto e aplica automaticamente todas as classes 
        // que implementam IEntityTypeConfiguration (os arquivos de mapeamento abaixo).
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(BazarDbContext).Assembly);
        base.OnModelCreating(modelBuilder);
    }
}