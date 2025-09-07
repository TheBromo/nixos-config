{
  self,
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    "${self}/modules/home-manager/git"
    "${self}/modules/home-manager/devtools"
    "${self}/modules/home-manager/console"
    "${self}/modules/home-manager/tmux"
    "${self}/modules/home-manager/nvim-config"
    "${self}/modules/home-manager/ghostty"
  ];
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/input-sources".xkb-options = [ "caps:escape" ];
    };
  };

  home = {
    username = "manuel";
    homeDirectory = "/home/manuel";
    stateVersion = "24.11";
    sessionVariables = {
      SHELL = "usr/bin/zsh";
    };
    keyboard = {
      options = [ "caps:escape" ];
    };
    packages = [
      pkgs._1password-cli
      pkgs._1password-gui
      pkgs.git-crypt
    ];
  };

  # programs.zsh.enable = true;
  programs.home-manager.enable = true;
}
