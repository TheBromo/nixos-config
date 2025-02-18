{
  root,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  imports = [
    "${root}/modules/home-manager/git"
    "${root}/modules/home-manager/devtools"
    "${root}/modules/home-manager/console"
    "${root}/modules/home-manager/tmux"
    "${root}/modules/home-manager/nvim-config"
    "${root}/modules/home-manager/ghostty"
  ];
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/input-sources".xkb-options = ["caps:escape"];
    };
  };

  home = {
    username = "manuel";
    homeDirectory = "/home/manuel";
    stateVersion = "24.11";
    sessionVariables = {
      SHELL = pkgs.zsh;
    };
    keyboard = {
      options = ["caps:escape"];
    };
    packages = [
      pkgs._1password-cli
      pkgs._1password-gui
      pkgs.git-crypt
    ];
  };

  programs.zsh.enable = true;
  programs.home-manager.enable = true;
}
