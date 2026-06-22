using Microsoft.AspNetCore.Authorization;
using System.Xml.Linq;
using Microsoft.AspNetCore.Mvc;
using PFMPManager.Api.DTOs;

namespace  PFMPManager.Api.Controllers
{
    [ApiController]

    [Route("api/news")]

    public class NewsController : ControllerBase
    {


        [Authorize]

        [HttpGet]

        public async Task<IActionResult> GetNews()
        {
            try {
                var rssUrl =   "https://www.cert.ssi.gouv.fr/feed/";

                using var httpClient = new HttpClient();

                var xml = await httpClient.GetStringAsync(rssUrl);

                var document = XDocument.Parse(xml);

                var rssItems = document.Descendants("item")
                .Select(i => new NewsDto
                {
                   Title = i.Element("title") ?.Value ?? string.Empty,
                   Link = i.Element("link")?.Value ?? string.Empty,
                   Description = i.Element("description")?.Value ?? string.Empty,
                   PublishedDate = i.Element("pubDate")?.Value ?? string.Empty,

                }).ToList();


            return Ok(rssItems);
           }catch
            {
                return StatusCode(500);
            }
        }
    }
}
