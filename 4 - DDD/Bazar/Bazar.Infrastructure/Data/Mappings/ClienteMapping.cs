using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Bazar.Domain.Entities;

namespace Bazar.Infrastructure.Data.Mappings;

public class ClienteMapping : IEntityTypeConfiguration<Cliente>
{
    public void Configure(EntityTypeBuilder<Cliente> builder)
    {
        builder.ToTable("clientes");

        builder.HasKey(c => c.Cpf);
        builder.Property(c => c.Cpf).HasColumnName("cpf").HasColumnType("varchar(20)");

        builder.Property(c => c.Nome).HasColumnName("nome").HasColumnType("varchar(255)").IsRequired();
        builder.Property(c => c.Email).HasColumnName("email").HasColumnType("varchar(255)");
        builder.Property(c => c.Telefone).HasColumnName("telefone").HasColumnType("varchar(50)");

        // O Value Object Endereco e achatado (flattened) para viver nas colunas da mesma tabela do cliente.
        builder.OwnsOne(c => c.Endereco, e =>
        {
            e.Property(en => en.Rua).HasColumnName("endereco").HasColumnType("varchar(500)");
            e.Property(en => en.Cidade).HasColumnName("cidade").HasColumnType("varchar(100)");
            e.Property(en => en.Estado).HasColumnName("estado").HasColumnType("varchar(50)");
            e.Property(en => en.Cep).HasColumnName("cep").HasColumnType("varchar(20)");
            e.Property(en => en.Pais).HasColumnName("pais").HasColumnType("varchar(50)");
        });
    }
}