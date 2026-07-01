using Bazar.Domain.ValueObjects;
using System;
using System.Collections.Generic;
using System.Text;

namespace Bazar.Domain.Entities
{
    public class Cliente
    {
        // Setters privados impedem que o estado da classe seja alterado de forma livre.
        // Qualquer alteracao deve ocorrer via metodos especificos da entidade (Rich Domain).
        public string Cpf { get; private set; }
        public string Nome { get; private set; }
        public string Email { get; private set; }
        public string Telefone { get; private set; }
        public Endereco Endereco { get; private set; }

        // O construtor principal obriga a criacao de um objeto valido desde o inicio.
        public Cliente(string cpf, string nome, string email, string telefone, Endereco endereco)
        {
            Cpf = cpf;
            Nome = nome;
            Email = email;
            Telefone = telefone;
            Endereco = endereco;
        }

        // O Entity Framework exige um construtor sem parametros. 
        // Ele e mantido como 'protected' para nao ser utilizado indevidamente pela aplicacao.
        protected Cliente() { }
    }
}
