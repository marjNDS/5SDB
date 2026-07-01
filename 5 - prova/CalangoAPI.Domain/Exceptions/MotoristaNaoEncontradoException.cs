namespace CalangoAPI.Domain.Exceptions;

public class MotoristaNaoEncontradoException : Exception
{
    public MotoristaNaoEncontradoException(Guid id)
        : base($"Motorista com o id '{id}' não foi encontrado.")
    {
    }
}