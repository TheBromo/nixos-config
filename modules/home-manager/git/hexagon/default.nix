{
  lib,
  ...
}:
{
  programs.git = {
    userName = lib.mkForce "Manuel Strenge";
    userEmail = lib.mkForce "manuel.strenge-ext@hexagon.com";
  };
}
