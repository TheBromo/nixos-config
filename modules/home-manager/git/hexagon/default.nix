{
  lib,
  ...
}:
{
  programs.git.settings = {
    user.Name = lib.mkForce "Manuel Strenge";
    user.Email = lib.mkForce "manuel.strenge-ext@hexagon.com";
  };
}
