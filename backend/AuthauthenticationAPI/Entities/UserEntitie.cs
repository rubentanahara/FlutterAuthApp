using Microsoft.AspNetCore.Identity;

namespace AuthauthenticationAPI.Entities
{
    public class UserEntitie : IdentityUser
    {
        public string Name { get; set; }
    }
}
