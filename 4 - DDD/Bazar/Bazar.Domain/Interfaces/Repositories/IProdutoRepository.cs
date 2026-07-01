using Bazar.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Interfaces.Repositories
{
    public interface IProdutoRepository
    {
        Task AdicionarAsync(Produto produto);
        Task AtualizarAsync(Produto produto);
        Task<Produto> ObterPorSkuAsync(string sku);
        Task<bool> ExistePorSkuAsync(string sku);
    }
}
