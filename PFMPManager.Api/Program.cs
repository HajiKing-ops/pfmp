using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PFMPManager.Api.Helpers;
using PFMPManager.Api.Data;
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

// Register application services used by controllers
builder.Services.AddScoped<IRoleService, RoleService>();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IPfmpAccessService, PfmpAccessService>();
builder.Services.AddScoped<IPlanningValidationService, PlanningValidationService>();


// CORS policy - allows the Flutter web client to send requests with cookies
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

// Configuration JWT authentication and custom validation events
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
      {
          // Read JWT setting from configuration
            var jwtKey = builder.Configuration["Jwt:Key"];
            var jwtIssuer = builder.Configuration["Jwt:Issuer"];
            var jwtAudience = builder.Configuration["Jwt:Audience"];
          
          // Validate issuer, audience, lifetime and signing key
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
              // Reading JWt from the HttpOnly AccessToken cookie
              OnMessageReceived = context => 
                {
                    var accessToken = context.Request.Cookies["AccessToken"];
                    if (!string.IsNullOrWhiteSpace(accessToken))
                    {
                        context.Token = accessToken;
                    }
                    return Task.CompletedTask;

                },
                // Checks the Fgp against the fingerprint_hash cliam
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

QuestPDF.Settings.License = LicenseType.Community; // Configure QuestPDF community license.


builder.Services.AddControllers(); // Enable API controller routing 

builder.Services.AddOpenApi(); //Enables OpenAPI/Swagger doc generation 

var app = builder.Build();

// Expose Swagger JSON only in development 
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection(); // Redirect http -> https

app.UseCors("AllowFlutterWeb"); // Apply CORS before authentication

app.UseAuthentication(); //  Validate the JWT from the AccessToken cookie
app.UseAuthorization(); // Enforce role and permission checks

app.MapControllers(); //Map controller routes

app.Run();
