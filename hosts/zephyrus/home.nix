{ config, pkgs, inputs, root, ... }:
{
  home.username = "manuel";
  home.homeDirectory = "/home/manuel";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    #apps
    firefox
    jetbrains.idea-ultimate
    nerdfonts
  ];

  home.file = {
    #".config/nvim".source = "${neovimConfigRepo}/";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
