using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Bazar.Domain.Entities;

namespace Bazar.Infrastructure.Data.Mappings;

public class ItemPedidoMapping : IEntityTypeConfiguration<ItemPedido>
{
    public void Configure(EntityTypeBuilder<ItemPedido> builder)
    {
        builder.ToTable("itens_pedido");

        builder.HasKey(i => i.OrderItemId);
        builder.Property(i => i.OrderItemId).HasColumnName("order_item_id").HasColumnType("varchar(50)");

        builder.Property(i => i.Sku).HasColumnName("sku").HasColumnType("varchar(100)");
        builder.Property(i => i.Quantidade).HasColumnName("quantidade").HasColumnType("integer");
        builder.Property(i => i.Moeda).HasColumnName("moeda").HasColumnType("varchar(10)");
        builder.Property(i => i.PrecoUnitario).HasColumnName("preco_unitario").HasColumnType("numeric(10,2)");

        // Chave Estrangeira para a tabela de produtos
        builder.HasOne<Produto>()
               .WithMany()
               .HasForeignKey(i => i.Sku);
    }
}