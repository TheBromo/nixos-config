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

  home = {
    username = "manuel";
    homeDirectory = "/Users/manuel";
    stateVersion = "24.11";
    sessionVariables = {
      SHELL = "usr/bin/zsh";
    };
    #keyboard = {
    #  options = ["caps:escape"];
    #};
    packages = [
      pkgs.git-crypt
    ];
  };
  programs.home-manager.enable = true;
}
