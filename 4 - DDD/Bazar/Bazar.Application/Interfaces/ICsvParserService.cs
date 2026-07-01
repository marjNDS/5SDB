using System.Collections.Generic;
using System.IO;

namespace Bazar.Application.Interfaces;

public interface ICsvParserService
{
    // Recebe um fluxo de dados de um arquivo e converte para uma lista de DTOs
    IEnumerable<T> LerCsv<T>(Stream fileStream);
}