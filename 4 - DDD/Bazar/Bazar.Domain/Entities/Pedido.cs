using Bazar.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Entities
{
    public class Pedido
    {
        public string OrderId { get; private set; }
        public string CpfCliente { get; private set; }
        public DateTime DataCompra { get; private set; }
        public DateTime DataPagamento { get; private set; }
        public string NivelServicoFrete { get; private set; }
        public StatusPedido Status { get; private set; }

        // O encapsulamento da lista impede que alguem adicione um item sem usar o metodo AdicionarItem.
        // Isso garante que o Pedido tenha controle total sobre o que acontece com ele.
        private readonly List<ItemPedido> _itens;
        public IReadOnlyCollection<ItemPedido> Itens => _itens.AsReadOnly();

        public Pedido(string orderId, string cpfCliente, DateTime dataCompra, DateTime dataPagamento, string nivelServicoFrete)
        {
            OrderId = orderId;
            CpfCliente = cpfCliente;
            DataCompra = dataCompra;
            DataPagamento = dataPagamento;
            NivelServicoFrete = nivelServicoFrete;
            Status = StatusPedido.Pendente; // Todo pedido nasce pendente
            _itens = new List<ItemPedido>();
        }

        protected Pedido()
        {
            _itens = new List<ItemPedido>();
        }

        public void AdicionarItem(ItemPedido item)
        {
            if (item == null) throw new ArgumentNullException(nameof(item));
            _itens.Add(item);
        }

        // A regra de negocio de calcular o valor total (necessaria para ordenar os pedidos) 
        // reside dentro do proprio pedido, e nao espalhada pelo sistema.
        public decimal CalcularValorTotal()
        {
            return _itens.Sum(i => i.Quantidade * i.PrecoUnitario);
        }

        public void MarcarComoAtendido()
        {
            Status = StatusPedido.Atendido;
        }
    }
}
