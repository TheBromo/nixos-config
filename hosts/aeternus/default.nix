{ pkgs, home-manager, inputs, root, neovim-config, ... }:
let
  neovim = neovim-config.makeDistribution pkgs;
in
{
  imports = [
    (root + "/modules/home-manager/git")
    (root + "/modules/home-manager/devtools")
    (root + "/modules/home-manager/console")
    (root + "/modules/home-manager/tmux")
  ];
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    neovim
  ];

  home.username = "thebromo";
  home.homeDirectory = "/home/thebromo";
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  programs.home-manager.enable = true;
}


