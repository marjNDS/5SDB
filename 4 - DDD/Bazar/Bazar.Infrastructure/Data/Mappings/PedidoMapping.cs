using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Bazar.Domain.Entities;

namespace Bazar.Infrastructure.Data.Mappings;

public class PedidoMapping : IEntityTypeConfiguration<Pedido>
{
    public void Configure(EntityTypeBuilder<Pedido> builder)
    {
        builder.ToTable("pedidos");

        builder.HasKey(p => p.OrderId);
        builder.Property(p => p.OrderId).HasColumnName("order_id").HasColumnType("varchar(50)");

        builder.Property(p => p.CpfCliente).HasColumnName("cpf_cliente").HasColumnType("varchar(20)");
        builder.Property(p => p.DataCompra).HasColumnName("data_compra").HasColumnType("timestamp");
        builder.Property(p => p.DataPagamento).HasColumnName("data_pagamento").HasColumnType("timestamp");
        builder.Property(p => p.NivelServicoFrete).HasColumnName("nivel_servico_frete").HasColumnType("varchar(50)");

        // Mapeia o Enum para ser salvo como string no banco
        builder.Property(p => p.Status)
               .HasColumnName("status")
               .HasColumnType("varchar(20)")
               .HasConversion<string>();

        // Configura o relacionamento 1:N com a tabela itens_pedido.
        // Como o backing field no domínio é "_itens", informamos isso ao EF.
        builder.Metadata.FindNavigation(nameof(Pedido.Itens))
               .SetPropertyAccessMode(PropertyAccessMode.Field);

        builder.HasMany(p => p.Itens)
               .WithOne()
               .HasForeignKey("OrderId") // Cria uma coluna de chave estrangeira oculta no EF
               .IsRequired()
               .OnDelete(DeleteBehavior.Cascade);

        // Chave Estrangeira explícita para Cliente
        builder.HasOne<Cliente>()
               .WithMany()
               .HasForeignKey(p => p.CpfCliente);
    }
}