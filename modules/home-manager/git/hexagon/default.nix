{ self, inputs, ... }:
{
  flake.homeModules.gitHexagon =
    { ... }:
    {
      git.userName = "Manuel Strenge";
      git.userEmail = "manuel.strenge-ext@hexagon.com";
    };
}
