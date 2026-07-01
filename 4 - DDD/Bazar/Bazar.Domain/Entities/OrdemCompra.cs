using Bazar.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Entities
{
    public class OrdemCompra
    {
        public int Id { get; private set; }
        public string Sku { get; private set; }
        public int QuantidadeComprar { get; private set; }
        public StatusCompra Status { get; private set; }
        public DateTime DataRegistro { get; private set; }

        public OrdemCompra(string sku, int quantidadeComprar)
        {
            Sku = sku;
            QuantidadeComprar = quantidadeComprar;
            Status = StatusCompra.Pendente;
            DataRegistro = DateTime.UtcNow;
        }

        protected OrdemCompra() { }

        public void MarcarComoRecebido()
        {
            Status = StatusCompra.Recebido;
        }
    }
}
