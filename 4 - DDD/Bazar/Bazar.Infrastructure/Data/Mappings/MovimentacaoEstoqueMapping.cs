using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Bazar.Domain.Entities;

namespace Bazar.Infrastructure.Data.Mappings;

public class MovimentacaoEstoqueMapping : IEntityTypeConfiguration<MovimentacaoEstoque>
{
    public void Configure(EntityTypeBuilder<MovimentacaoEstoque> builder)
    {
        builder.ToTable("movimentacao_estoque");

        builder.HasKey(m => m.Id);
        builder.Property(m => m.Id).HasColumnName("id_movimento").UseIdentityColumn();

        // O order_id não é obrigatório porque pode ser uma entrada do fornecedor
        builder.Property(m => m.OrderId).HasColumnName("order_id").HasColumnType("varchar(50)").IsRequired(false);
        builder.Property(m => m.Sku).HasColumnName("sku").HasColumnType("varchar(100)");
        builder.Property(m => m.QuantidadeAnterior).HasColumnName("quantidade_anterior").HasColumnType("integer");
        builder.Property(m => m.QuantidadeMovimentada).HasColumnName("quantidade_movimentada").HasColumnType("integer");
        builder.Property(m => m.SaldoFinal).HasColumnName("saldo_final").HasColumnType("integer");
        builder.Property(m => m.TipoMovimentacao).HasColumnName("tipo_movimentacao").HasColumnType("varchar(10)");
        builder.Property(m => m.DataRegistro).HasColumnName("data_registro").HasColumnType("timestamp");

        builder.HasOne<Produto>()
               .WithMany()
               .HasForeignKey(m => m.Sku);

        builder.HasOne<Pedido>()
               .WithMany()
               .HasForeignKey(m => m.OrderId)
               .IsRequired(false);
    }
}