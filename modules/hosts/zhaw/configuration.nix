{ self, inputs, ... }:
{
  flake.homeModules.zhawConfiguration =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      imports = [
        (self.lib.gitModule { signing = false; })
        self.homeModules.devtools
        self.homeModules.console
        self.homeModules.info
        self.homeModules.dvt
        self.homeModules.dvd
        self.homeModules.wsswitch
        self.homeModules.tmux
        self.homeModules.nvimConfig
        self.homeModules.claude
      ];

      home = {
        username = "strenman";
        homeDirectory = "/home/strenman";
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
