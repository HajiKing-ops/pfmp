using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data; // AppDBContext our custom database context
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.Security.Cryptography;
using QuestPDF.Infrastructure;
using PFMPManager.Api.Services;




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

builder.Services.AddScoped<IRoleService, RoleService>();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();


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

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
      {
          var jwtKey = builder.Configuration["Jwt:Key"];
          var jwtIssuer = builder.Configuration["Jwt:Issuer"];
          var jwtAudience = builder.Configuration["Jwt:Audience"];

          options.TokenValidationParameters = new TokenValidationParameters
          {
              ValidateIssuer = true,
              ValidateAudience = true,
              ValidateLifetime = true,
              ValidateIssuerSigningKey = true,

              ValidIssuer = jwtIssuer,
              ValidAudience = jwtAudience,
              IssuerSigningKey = new SymmetricSecurityKey(
                  Encoding.UTF8.GetBytes(jwtKey!)),
              ClockSkew = TimeSpan.Zero
          };
      });

builder.Services.AddAuthorization(); 

QuestPDF.Settings.License = LicenseType.Community; // I tell QuestPDF that I use the Community license mode. 


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

app.UseAuthentication(); // read and verify  JWT token
app.UseAuthorization(); // check permission/role

app.MapControllers(); //Map [ApiController]routes ->  makes your controller reachable

app.Run();
