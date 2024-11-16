{ pkgs,... }: {
  programs.steam = {
    enable = true;
    #jremotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  environment.systemPackages = with pkgs; [
    legcord
  ];
}
