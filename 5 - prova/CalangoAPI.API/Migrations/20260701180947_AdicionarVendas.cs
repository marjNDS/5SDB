using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CalangoAPI.API.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarVendas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Passagens",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ViagemId = table.Column<Guid>(type: "uuid", nullable: false),
                    ParadaOrigemId = table.Column<Guid>(type: "uuid", nullable: false),
                    ParadaDestinoId = table.Column<Guid>(type: "uuid", nullable: false),
                    PassageiroId = table.Column<Guid>(type: "uuid", nullable: false),
                    Assento = table.Column<int>(type: "integer", nullable: false),
                    ValorPago = table.Column<decimal>(type: "numeric", nullable: false),
                    DataCompra = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Passagens", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Passagens_ViagemId_Assento",
                table: "Passagens",
                columns: new[] { "ViagemId", "Assento" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Passagens");
        }
    }
}
