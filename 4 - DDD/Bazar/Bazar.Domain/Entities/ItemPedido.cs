using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Entities
{
    public class ItemPedido
    {
        public string OrderItemId { get; private set; }
        public string Sku { get; private set; }
        public int Quantidade { get; private set; }
        public string Moeda { get; private set; }
        public decimal PrecoUnitario { get; private set; }

        public ItemPedido(string orderItemId, string sku, int quantidade, string moeda, decimal precoUnitario)
        {
            OrderItemId = orderItemId;
            Sku = sku;
            Quantidade = quantidade;
            Moeda = moeda;
            PrecoUnitario = precoUnitario;
        }

        protected ItemPedido() { }
    }
}
