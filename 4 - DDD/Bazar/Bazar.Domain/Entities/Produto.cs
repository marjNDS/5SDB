using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Entities
{
    public class Produto
    {
        public string Sku { get; private set; }
        public string Upc { get; private set; }
        public string Nome { get; private set; }
        public int EstoqueAtual { get; private set; }
        public int LoteReposicao { get; private set; }

        public Produto(string sku, string upc, string nome, int loteReposicao = 10)
        {
            Sku = sku;
            Upc = upc;
            Nome = nome;
            EstoqueAtual = 0;
            LoteReposicao = loteReposicao;
        }

        protected Produto() { }

        // Metodos de negocio: O calculo e a validacao do estoque ficam encapsulados na propria entidade.
        public void DebitarEstoque(int quantidade)
        {
            if (quantidade <= 0)
                throw new ArgumentException("A quantidade a debitar deve ser maior que zero.");

            if (quantidade > EstoqueAtual)
                throw new InvalidOperationException("Estoque insuficiente para realizar o debito.");

            EstoqueAtual -= quantidade;
        }

        public void CreditarEstoque(int quantidade)
        {
            if (quantidade <= 0)
                throw new ArgumentException("A quantidade a creditar deve ser maior que zero.");

            EstoqueAtual += quantidade;
        }
    }
}
