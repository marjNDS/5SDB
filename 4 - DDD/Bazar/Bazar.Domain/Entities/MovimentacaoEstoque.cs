using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Entities
{
    public class MovimentacaoEstoque
    {
        public int Id { get; private set; }
        public string OrderId { get; private set; } // Opcional, pode ser nulo se for entrada de fornecedor
        public string Sku { get; private set; }
        public int QuantidadeAnterior { get; private set; }
        public int QuantidadeMovimentada { get; private set; }
        public int SaldoFinal { get; private set; }
        public string TipoMovimentacao { get; private set; } // "ENTRADA" ou "SAIDA"
        public DateTime DataRegistro { get; private set; }

        // O uso de construtores privados e metodos estaticos (Factory Methods) 
        // garante que a classe só seja instanciada de forma consistente com as regras de negocio.
        protected MovimentacaoEstoque() { }

        public static MovimentacaoEstoque CriarSaida(string orderId, string sku, int quantidadeAnterior, int quantidadeDebitada)
        {
            return new MovimentacaoEstoque
            {
                OrderId = orderId,
                Sku = sku,
                QuantidadeAnterior = quantidadeAnterior,
                QuantidadeMovimentada = quantidadeDebitada,
                SaldoFinal = quantidadeAnterior - quantidadeDebitada,
                TipoMovimentacao = "SAIDA",
                DataRegistro = DateTime.UtcNow
            };
        }

        public static MovimentacaoEstoque CriarEntrada(string sku, int quantidadeAnterior, int quantidadeCreditada)
        {
            return new MovimentacaoEstoque
            {
                OrderId = null, // Entradas nao possuem vinculo com pedido de cliente
                Sku = sku,
                QuantidadeAnterior = quantidadeAnterior,
                QuantidadeMovimentada = quantidadeCreditada,
                SaldoFinal = quantidadeAnterior + quantidadeCreditada,
                TipoMovimentacao = "ENTRADA",
                DataRegistro = DateTime.UtcNow
            };
        }
    }
}
