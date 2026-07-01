using CalangoAPI.Application.Interfaces;
using CalangoAPI.Application.Interfaces;
using CalangoAPI.Application.Services;
using CalangoAPI.Application.Services;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Domain.Services;
using CalangoAPI.Infrastructure.Data.Context;
using CalangoAPI.Infrastructure.Data.Context;
using CalangoAPI.Infrastructure.Data.Repositories;
using CalangoAPI.Infrastructure.Data.Repositories;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Recupera a string de conexão do appsettings.json
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// Substituição do provedor In-Memory pelo PostgreSQL
builder.Services.AddDbContext<OnibusDbContext>(options =>
    options.UseNpgsql(connectionString, b => b.MigrationsAssembly("CalangoAPI.API")));

builder.Services.AddScoped<IOnibusRepository, OnibusRepository>();
builder.Services.AddScoped<IFrotaAppService, FrotaAppService>();
builder.Services.AddScoped<IRotaRepository, RotaRepository>();
builder.Services.AddScoped<IMalhaAppService, MalhaAppService>();
builder.Services.AddScoped<IViagemRepository, ViagemRepository>();
builder.Services.AddScoped<IOperacionalAppService, OperacionalAppService>();
builder.Services.AddSingleton<CalculadoraPrecoService>();
builder.Services.AddScoped<IPassagemRepository, PassagemRepository>();
builder.Services.AddScoped<IVendasAppService, VendasAppService>();
builder.Services.AddSingleton<ValidadorEscalaService>();
builder.Services.AddScoped<IMotoristaRepository, MotoristaRepository>();
builder.Services.AddScoped<IMotoristasAppService, MotoristasAppService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();
app.MapControllers();

app.Run();