using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CalangoAPI.API.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarGestaoMotoristas : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "MotoristaId",
                table: "Viagens",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Motoristas",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Nome = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    CartaConducao = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Motoristas", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Viagens_MotoristaId",
                table: "Viagens",
                column: "MotoristaId");

            migrationBuilder.AddForeignKey(
                name: "FK_Viagens_Motoristas_MotoristaId",
                table: "Viagens",
                column: "MotoristaId",
                principalTable: "Motoristas",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Viagens_Motoristas_MotoristaId",
                table: "Viagens");

            migrationBuilder.DropTable(
                name: "Motoristas");

            migrationBuilder.DropIndex(
                name: "IX_Viagens_MotoristaId",
                table: "Viagens");

            migrationBuilder.DropColumn(
                name: "MotoristaId",
                table: "Viagens");
        }
    }
}
