{ self, ... }:
{
  flake.homeModules.manuelDarwinConfiguration =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      imports = [
        (self.lib.gitModule { })
        self.homeModules.darwinTools
        self.homeModules.devtools
        self.homeModules.console
        self.homeModules.kubernetes
        self.homeModules.node
        self.homeModules.go
        self.homeModules.starship
        self.homeModules.atuin
        self.homeModules.direnv
        self.homeModules.bat
        self.homeModules.wt
        self.homeModules.tmux
        self.homeModules.claude
        self.homeModules.codex
        self.homeModules.herdr
        self.homeModules.info
        self.homeModules.dvt
        self.homeModules.dvd
        self.homeModules.wsswitch
        self.homeModules.terraform
        (self.lib.ghosttyModule { isDarwin = true; })
        self.homeModules.TX-02
        self.homeModules.nvimConfig
        self.homeModules.zedCyberdream
      ];

      home = {
        username = "manuel";
        homeDirectory = "/Users/manuel";
        stateVersion = "24.11";
        sessionVariables = {
          SHELL = "${pkgs.zsh}/bin/zsh";
        };
      };

      programs.home-manager.enable = true;
    };
}
