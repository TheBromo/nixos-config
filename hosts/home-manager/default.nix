{root,pkgs,...}:{
  nixpkgs.config.allowUnfree = true;
  imports = [
        "${root}/modules/home-manager/git"
        "${root}/modules/home-manager/devtools"
        "${root}/modules/home-manager/console"
        "${root}/modules/home-manager/tmux"
        "${root}/modules/home-manager/nvim-config"
  ];
  
  home= {
    username = "manuel";
    homeDirectory = "/home/manuel";
    stateVersion = "24.11";
    sessionVariables = {
      SHELL = pkgs.zsh;
    };
    file = {};
    packages =[
      pkgs._1password-cli
      pkgs._1password-gui

    ];
  };

  programs.zsh.enable = true;
  programs.home-manager.enable = true;
}
