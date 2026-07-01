using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Bazar.Domain.Entities;

namespace Bazar.Infrastructure.Data.Mappings;

public class ProdutoMapping : IEntityTypeConfiguration<Produto>
{
    public void Configure(EntityTypeBuilder<Produto> builder)
    {
        builder.ToTable("produtos");

        builder.HasKey(p => p.Sku);
        builder.Property(p => p.Sku).HasColumnName("sku").HasColumnType("varchar(100)");

        builder.Property(p => p.Upc).HasColumnName("upc").HasColumnType("varchar(50)");
        builder.Property(p => p.Nome).HasColumnName("nome_produto").HasColumnType("varchar(255)").IsRequired();

        builder.Property(p => p.EstoqueAtual).HasColumnName("estoque_atual").HasColumnType("integer").HasDefaultValue(0);
        builder.Property(p => p.LoteReposicao).HasColumnName("lote_reposicao").HasColumnType("integer").HasDefaultValue(10);
    }
}