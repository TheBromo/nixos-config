{ ... }:
{
  flake.nixosModules.tailscale = {
    services.tailscale = {
      enable = true;
      extraDaemonFlags = [ "--encrypt-state=false" ];
    };
  };
}
