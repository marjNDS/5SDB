using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Bazar.Domain.Entities;

namespace Bazar.Infrastructure.Data.Mappings;

public class OrdemCompraMapping : IEntityTypeConfiguration<OrdemCompra>
{
    public void Configure(EntityTypeBuilder<OrdemCompra> builder)
    {
        builder.ToTable("ordens_compra");

        builder.HasKey(o => o.Id);
        builder.Property(o => o.Id).HasColumnName("id_compra").UseIdentityColumn();

        builder.Property(o => o.Sku).HasColumnName("sku").HasColumnType("varchar(100)");
        builder.Property(o => o.QuantidadeComprar).HasColumnName("quantidade_comprar").HasColumnType("integer");
        builder.Property(o => o.DataRegistro).HasColumnName("data_registro").HasColumnType("timestamp");

        builder.Property(o => o.Status)
               .HasColumnName("status")
               .HasColumnType("varchar(20)")
               .HasConversion<string>();

        builder.HasOne<Produto>()
               .WithMany()
               .HasForeignKey(o => o.Sku);
    }
}