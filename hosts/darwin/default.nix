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

  home = {
    username = "manuel";
    homeDirectory = "/Users/manuel";
    stateVersion = "24.11";
    sessionVariables = {
      SHELL = pkgs.zsh;
    };
    packages = [
      pkgs.git-crypt
    ];
  };
  programs.home-manager.enable = true;
}
