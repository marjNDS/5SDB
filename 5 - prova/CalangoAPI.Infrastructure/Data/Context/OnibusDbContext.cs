using CalangoAPI.Domain.Entities.Frota;
using CalangoAPI.Domain.Entities.Malha;
using CalangoAPI.Domain.Entities.Operacional;
using CalangoAPI.Domain.Entities.RecursosHumanos;
using CalangoAPI.Domain.Entities.Vendas;
using CalangoAPI.Domain.Entities.RecursosHumanos;
using CalangoAPI.Domain.Entities.Identidade;
using Microsoft.EntityFrameworkCore;

namespace CalangoAPI.Infrastructure.Data.Context;

public class OnibusDbContext : DbContext
{
    public OnibusDbContext(DbContextOptions<OnibusDbContext> options) : base(options) { }

    public DbSet<Onibus> Onibus { get; set; }
    public DbSet<Rota> Rotas { get; set; }
    public DbSet<Parada> Paradas { get; set; }
    public DbSet<Viagem> Viagens { get; set; }
    public DbSet<Passagem> Passagens { get; set; }
    public DbSet<Motorista> Motoristas { get; set; }
    public DbSet<Usuario> Usuarios { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Mapeamento Frota (Já existente)
        modelBuilder.Entity<Onibus>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Placa).IsRequired().HasMaxLength(10);
            entity.Property(e => e.Tipo).IsRequired().HasMaxLength(20);
        });

        // Mapeamento Rota
        modelBuilder.Entity<Rota>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(100);

            // O PostgreSQL suporta arrays nativamente para tipos primitivos
            entity.Property(e => e.PontosDeVendaIds).HasColumnType("integer[]");

            // Relação 1:N (Aggregate Root)
            entity.HasMany(e => e.Paradas)
                  .WithOne()
                  .HasForeignKey(p => p.RotaId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Mapeamento Parada
        modelBuilder.Entity<Parada>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.NomeLocalidade).IsRequired().HasMaxLength(100);
        });

        // Mapeamento Viagem
        modelBuilder.Entity<Viagem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Status).IsRequired().HasMaxLength(20);

            // Relacionamentos: Impede a exclusão de rotas/ônibus se houver viagens
            entity.HasOne<Rota>()
                  .WithMany()
                  .HasForeignKey(e => e.RotaId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne<Onibus>()
                  .WithMany()
                  .HasForeignKey(e => e.OnibusId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne<Motorista>()
                .WithMany()
                .HasForeignKey(e => e.MotoristaId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        // Mapeamento Passagem
        modelBuilder.Entity<Passagem>(entity =>
        {
            entity.HasKey(e => e.Id);

            // Indice composto unico para evitar venda dupla do mesmo assento na mesma viagem
            entity.HasIndex(e => new { e.ViagemId, e.Assento }).IsUnique();
        });

        // Mapeamento Motorista
        modelBuilder.Entity<Motorista>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Nome).IsRequired().HasMaxLength(150);
            entity.Property(e => e.CartaConducao).IsRequired().HasMaxLength(20);
        });

        //Mapeamento Usuario
        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Email).IsRequired().HasMaxLength(150);
            entity.Property(e => e.Role).IsRequired().HasMaxLength(20);
        });

        base.OnModelCreating(modelBuilder);
    }
}