using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.ValueObjects
{
    public record Endereco(
    string Rua,
    string Cidade,
    string Estado,
    string Cep,
    string Pais
);
}
