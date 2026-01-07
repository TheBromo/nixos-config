{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    # TODO: Enable if using Steam Remote Play or dedicated server
    # jremotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = [
    pkgs.legcord
  ];
}
