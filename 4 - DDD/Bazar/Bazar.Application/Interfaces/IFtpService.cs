using System.IO;
using System.Threading.Tasks;

namespace Bazar.Application.Interfaces;

public interface IFtpService
{
    // Baixa o arquivo do FTP e o disponibiliza em memoria para ser lido pelo CsvParser
    Task<Stream> BaixarArquivoAsync(string caminhoArquivoFtp);
}