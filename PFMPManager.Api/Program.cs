using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PFMPManager.Api.Data; // AppDBContext our custom database context
using PFMPManager.Api.Helpers;
using PFMPManager.Api.Services;
using QuestPDF.Infrastructure;





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
builder.Services.AddScoped<IPfmpAccessService, PfmpAccessService>();
builder.Services.AddScoped<IPlanningValidationService, PlanningValidationService>();


// CORS policy - allows the Flutter web client to call this API from any origin 
builder.Services.AddCors(options => 
{
    options.AddPolicy("AllowFlutterWeb", policy =>
    {
        policy.WithOrigins("http://localhost:65427")
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials();
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
          options.Events = new JwtBearerEvents
          {
              OnTokenValidated = context =>
              {
                  var fingerprintClaim = context.Principal?.FindFirst("fingerprint_hash")?.Value;
                  var fingerprintCookie = context.HttpContext.Request.Cookies["Fgp"];

                  if (string.IsNullOrWhiteSpace(fingerprintClaim) || string.IsNullOrWhiteSpace(fingerprintCookie))
                    {
                      context.Fail("Fingerprint missing");
                      return Task.CompletedTask;
                  }
                  var fingerprintCookieHash = JwtHelper.HashFingerprint(fingerprintCookie);
                  if (!string.Equals(fingerprintClaim, fingerprintCookieHash, StringComparison.Ordinal))
                  {
                      context.Fail("Invalid fingerprint");
                      return Task.CompletedTask;
                  }
                  return Task.CompletedTask;
              }
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
