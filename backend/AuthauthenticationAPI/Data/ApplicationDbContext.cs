using AuthauthenticationAPI.Entities;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace AuthauthenticationAPI.Data
{
    public class ApplicationDbContext : IdentityDbContext<UserEntitie>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
            
        }
    }
}
