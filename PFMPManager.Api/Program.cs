using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data; // AppDBContext our custom database context
using Microsoft.Net.Http.Headers; 


var builder = WebApplication.CreateBuilder(args);

// Register AppDbContext with Mysql using the connection string from appsettings.json 
builder.Services.AddDbContext<AppDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

    options.UseMySql
        (
            connectionString,
            ServerVersion.AutoDetect(connectionString)
        );
});

// CORS policy - allows the Flutter web client to call this API from any origin 
builder.Services.AddCors(options => 
{
    options.AddPolicy("AllowFlutterWeb", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddControllers(); // Enable API controller routing 
// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi(); //Enables OpenAPI/Swagger doc generation 

var app = builder.Build();

// Expose Swagger JSON only in development 
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection(); // Redirect http -> https

app.UseCors("AllowFlutterWeb"); // apply CORS policy 

app.UseAuthentication();

app.MapControllers(); //Map [ApiController]routes ->  makes your controller reachable

app.Run();
