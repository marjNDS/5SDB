using CalangoAPI.API;
using CalangoAPI.Application.Interfaces;
using CalangoAPI.Application.Services;
using CalangoAPI.Domain.Interfaces.Repositories;
using CalangoAPI.Domain.Interfaces.Security;
using CalangoAPI.Domain.Services;
using CalangoAPI.Infrastructure.Data.Context;
using CalangoAPI.Infrastructure.Data.Repositories;
using CalangoAPI.Infrastructure.Security;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using Scalar.AspNetCore;
using System.Text;


var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

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
builder.Services.AddScoped<IUsuarioRepository, UsuarioRepository>();
builder.Services.AddScoped<ITokenService, JwtTokenService>();
builder.Services.AddScoped<IAuthAppService, AuthAppService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configuração JWT
var key = Encoding.ASCII.GetBytes(builder.Configuration["Jwt:Key"]!);
builder.Services.AddAuthentication(x =>
{
    x.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    x.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(x =>
{
    x.RequireHttpsMetadata = false;
    x.SaveToken = true;
    x.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidateAudience = true,
        ValidAudience = builder.Configuration["Jwt:Audience"]
    };
});

builder.Services.AddOpenApi(options =>
{
    options.AddDocumentTransformer<BearerSecuritySchemeTransformer>();
});

var app = builder.Build();

app.MapOpenApi();
app.MapScalarApiReference(options =>
{
    options.WithTitle("Calango API - Sistema de Autocarros");
});

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();