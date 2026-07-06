using Microsoft.AspNetCore.Authorization;
using System.Xml.Linq;
using Microsoft.AspNetCore.Mvc;
using PFMPManager.Api.DTOs;

namespace  PFMPManager.Api.Controllers
{
    // Provides cybersecurity news from the CERT-FR RSS feed
    [ApiController]
    [Route("api/news")]
    public class NewsController : ControllerBase
    {
        // Retrieves cybersecurity news from the CERT-FR RSS feed
        [Authorize]
        [HttpGet]
        public async Task<IActionResult> GetNews()
        {
            try {
                var rssUrl =   "https://www.cert.ssi.gouv.fr/feed/";

                using var httpClient = new HttpClient();
                // Fetch the RSS feed from CERT-FR
                var xml = await httpClient.GetStringAsync(rssUrl);

                var document = XDocument.Parse(xml);
                // Parse RSS items into DTOs returned to the frontend
                var rssItems = document.Descendants("item")
                .Select(i => new NewsDto
                {
                   Title = i.Element("title")?.Value ?? string.Empty,
                   Link = i.Element("link")?.Value ?? string.Empty,
                   Description = i.Element("description")?.Value ?? string.Empty,
                   PublishedDate = i.Element("pubDate")?.Value ?? string.Empty,

                }).ToList();


            return Ok(rssItems);
           }catch
            {
                return StatusCode(500, "Impossible de recuperer les actualites.");
            }
        }
    }
}
