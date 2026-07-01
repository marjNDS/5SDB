using Bazar.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Interfaces.Repositories
{
    public interface IOrdemCompraRepository
    {
        Task AdicionarAsync(OrdemCompra ordemCompra);
        Task<bool> ExisteOrdemPendenteParaSkuAsync(string sku);
    }
}
