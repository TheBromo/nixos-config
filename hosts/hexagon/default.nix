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
    "${self}/modules/home-manager/ghostty"
  ];
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/input-sources".xkb-options = [ "caps:escape" ];
    };
  };
  nixGL = {
    packages = nixgl.packages;
  };

  services.vicinae = {
    enable = true;
    autoStart = true;
    settings = {
      faviconService = "twenty"; # twenty | google | none
      font.size = 11;
      popToRootOnClose = false;
      rootSearch.searchFiles = false;
      theme.name = "vicinae-dark";
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
    };
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
      pkgs._1password-cli
      pkgs._1password-gui
      pkgs.git-crypt
      pkgs.wl-clipboard
      pkgs.timewarrior
    ];
  };

  # programs.zsh.enable = true;
  programs.home-manager.enable = true;
}
