{ self, inputs, ... }:
{
  flake.homeModules.gitHexagon =
    { lib, ... }:
    {
      programs.git.settings = {
        user = {
          Name = lib.mkForce "Manuel Strenge";
          Email = lib.mkForce "manuel.strenge-ext@hexagon.com";
        };
      };
    };
}
