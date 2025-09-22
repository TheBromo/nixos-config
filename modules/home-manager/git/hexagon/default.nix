{
  lib,
  ...
}:
{

  programs.git = {
    userName = lib.mkForce "Manuel Strenge";
    # extraConfig.gpg = lib.mkForce { };
    userEmail = lib.mkForce "manuel.strenge-ext@hexagon.com";
    # signing = lib.mkForce {
    #   signByDefault = false;
    # };
  };
}
