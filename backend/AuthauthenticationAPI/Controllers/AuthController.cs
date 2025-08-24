using AuthauthenticationAPI.Entities;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace AuthauthenticationAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : Controller
    {
        private readonly UserManager<UserEntitie> _userManager;
        private readonly SignInManager<UserEntitie> _signInManager;
        private readonly string? _jwtKey;
        private readonly string? _jwtIssuer;
        private readonly string? _jwtAudience;
        private readonly int _jwtExpiry;

        public AuthController(UserManager<UserEntitie> userManager,SignInManager<UserEntitie> signInManager, IConfiguration configuration)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _jwtKey = configuration["Jwt:Key"];
            _jwtIssuer = configuration["Jwt:Issuer"];
            _jwtAudience = configuration["Jwt:Audience"];
            _jwtExpiry = int.Parse(configuration["Jwt:ExpiryMinutes"]);

        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterEntitie model)
        {
            if (model == null 
                || string.IsNullOrEmpty(model.Name)
                || string.IsNullOrEmpty(model.Email)
                || string.IsNullOrEmpty(model.Password))
            {
                return BadRequest("Invalid request");
            }
            if (await _userManager.FindByEmailAsync(model.Email) != null)
            {
                return BadRequest(new { message = "User with this email already exists" });
            }
            var user = new UserEntitie
            {
                UserName = model.Email,
                Email = model.Email,
                Name = model.Name
            };
            var result = await _userManager.CreateAsync(user, model.Password);
            if (result.Succeeded)
            {
                await _userManager.AddToRoleAsync(user, "User");
                return Json(new { success = true, UserName = user.UserName, Email = user.Email, Name = user.Name });
            }
            return BadRequest(result.Errors);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginEntitie model)
        {
            if (model == null
                || string.IsNullOrEmpty(model.Email)
                || string.IsNullOrEmpty(model.Password))
            {
                return BadRequest("Invalid request");
            }
            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user == null)
            {
                return Unauthorized(new {success = false,message = "Invalid Email or Password"});
            }
            var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password, false);
            
            if(!result.Succeeded)
            {
                return Unauthorized(new { success = false, message = "Invalid Email or Password" });
            }
            var token = GenerateJwtToken(user);
            return Ok(new { success = true, token.Result });
        }

        private async Task<string> GenerateJwtToken(UserEntitie user)
        {
            var userRoles = await _userManager.GetRolesAsync(user);
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim("Name", user.Name)
            };
            if (userRoles.Any())
            {
                claims.Add(new Claim("role", userRoles.First()));
            }

            claims.AddRange(userRoles.Select(role => new Claim(ClaimTypes.Role, role)));
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtKey));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.Now.AddMinutes(_jwtExpiry),
                signingCredentials: creds
            );
            return new JwtSecurityTokenHandler().WriteToken(token);
        }

    }
  
}
