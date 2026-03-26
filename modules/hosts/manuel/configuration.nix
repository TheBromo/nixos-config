{ self, ... }:
{
  flake.homeModules.manuelConfiguration =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      imports = [
        (self.lib.gitModule { signing = false; })
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
        self.homeModules.ros
        self.homeModules.terraform
        self.homeModules.info
        self.homeModules.dvt
        self.homeModules.dvd
        self.homeModules.wsswitch
        self.homeModules.tmux
        self.homeModules.nvimConfig
        self.homeModules.ghostty
        self.homeModules.fluentui-emoji
        self.homeModules.claude
      ];

      home = {
        username = "manuel";
        homeDirectory = "/home/manuel";
        stateVersion = "24.11";
        keyboard = {
          options = [ "caps:escape" ];
        };
        packages = [
          pkgs.git-crypt
        ];
      };

      programs.home-manager.enable = true;
    };
}
