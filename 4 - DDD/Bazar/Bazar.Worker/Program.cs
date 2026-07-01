using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Bazar.Application.Interfaces;
using Bazar.Application.UseCases;
using Bazar.Domain.Interfaces.Repositories;
using Bazar.Domain.Services;
using Bazar.Infrastructure.Data;
using Bazar.Infrastructure.Repositories;
using Bazar.Infrastructure.Services;

var builder = WebApplication.CreateBuilder(args);

// 1. Configuração do Servidor Web e Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// 2. Configuração do Banco de Dados
builder.Services.AddDbContext<BazarDbContext>(options =>
    options.UseNpgsql("Host=localhost;Port=5432;Database=MinimundoBazar;Username=postgres;Password=suasenha"));

// 3. Injeção de Dependência: Repositórios
builder.Services.AddScoped<IClienteRepository, ClienteRepository>();
builder.Services.AddScoped<IProdutoRepository, ProdutoRepository>();
builder.Services.AddScoped<IPedidoRepository, PedidoRepository>();
builder.Services.AddScoped<IMovimentacaoEstoqueRepository, MovimentacaoEstoqueRepository>();
builder.Services.AddScoped<IOrdemCompraRepository, OrdemCompraRepository>();

// 4. Injeção de Dependência: Serviços
builder.Services.AddScoped<ICsvParserService, CsvParserService>();
builder.Services.AddScoped<IFtpService, FtpService>();

// 5. Injeção de Dependência: Domínio e Aplicação
builder.Services.AddScoped<AtendimentoPedidoDomainService>();
builder.Services.AddScoped<ImportarPedidosMarketplaceUseCase>();
builder.Services.AddScoped<ImportarAtualizacaoEstoqueFornecedorUseCase>();

var app = builder.Build();

// Configuração do pipeline de requisições HTTP
app.UseSwagger();
app.UseSwaggerUI();

app.UseAuthorization();
app.MapControllers();

app.Run();