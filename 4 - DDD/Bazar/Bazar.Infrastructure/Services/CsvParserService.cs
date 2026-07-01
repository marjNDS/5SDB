using Bazar.Application.Interfaces;
using CsvHelper;
using CsvHelper.Configuration;
using System.Collections.Generic;
using System.Formats.Asn1;
using System.Globalization;
using System.IO;
using System.Linq;

namespace Bazar.Infrastructure.Services;

public class CsvParserService : ICsvParserService
{
    public IEnumerable<T> LerCsv<T>(Stream fileStream)
    {
        // O StreamReader precisa ficar aberto para o CsvReader consumir
        var reader = new StreamReader(fileStream);

        var config = new CsvConfiguration(CultureInfo.InvariantCulture)
        {
            HasHeaderRecord = true,
            Delimiter = ",",
            MissingFieldFound = null // Evita quebra caso o CSV venha com colunas faltando
        };

        var csv = new CsvReader(reader, config);

        // Retorna a lista materializada em memoria
        return csv.GetRecords<T>().ToList();
    }
}