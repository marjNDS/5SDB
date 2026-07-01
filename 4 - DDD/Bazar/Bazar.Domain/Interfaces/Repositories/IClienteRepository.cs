using Bazar.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Interfaces.Repositories
{
    public interface IClienteRepository
    {
        Task AdicionarAsync(Cliente cliente);
        Task<bool> ExistePorCpfAsync(string cpf);
    }
}
