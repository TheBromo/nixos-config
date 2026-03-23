{
  self,
  pkgs,
  nixgl,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  imports = [
    "${self}/modules/home-manager/git"
    "${self}/modules/home-manager/git/hexagon"
    "${self}/modules/home-manager/devtools"
    "${self}/modules/home-manager/console"
    "${self}/modules/home-manager/tmux"
    "${self}/modules/home-manager/nvim-config"
    "${self}/modules/home-manager/timewarrior-auto"
  ];
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/input-sources".xkb-options = [ "caps:escape" ];
    };
  };
  targets.genericLinux.nixGL = {
    packages = nixgl.packages;
  };

  home = {
    username = "strenge";
    homeDirectory = "/home/strenge";
    stateVersion = "24.11";
    sessionVariables = {
    };
    keyboard = {
      options = [ "caps:escape" ];
    };
    packages = [
      pkgs.git-crypt
      pkgs.wl-clipboard
      pkgs.timewarrior
    ];
  };

  # programs.zsh.enable = true;
  programs.home-manager.enable = true;
}
