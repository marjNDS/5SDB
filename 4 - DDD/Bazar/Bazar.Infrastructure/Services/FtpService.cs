using System.IO;
using System.Net;
using System.Threading.Tasks;
using Bazar.Application.Interfaces;

namespace Bazar.Infrastructure.Services;

public class FtpService : IFtpService
{
    // Em um cenario real, as credenciais viriam do appsettings.json via Injeção de Dependência.
    public async Task<Stream> BaixarArquivoAsync(string caminhoArquivoFtp)
    {
        var request = (FtpWebRequest)WebRequest.Create(caminhoArquivoFtp);
        request.Method = WebRequestMethods.Ftp.DownloadFile;

        // request.Credentials = new NetworkCredential("usuario", "senha");

        var response = (FtpWebResponse)await request.GetResponseAsync();

        // Retorna o fluxo de dados diretamente do FTP para a memória do sistema
        var memoryStream = new MemoryStream();
        using (var responseStream = response.GetResponseStream())
        {
            await responseStream.CopyToAsync(memoryStream);
        }

        memoryStream.Position = 0; // Reseta o ponteiro para leitura do CsvParser
        return memoryStream;
    }
}