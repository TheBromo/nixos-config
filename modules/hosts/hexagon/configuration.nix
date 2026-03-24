{ self, inputs, ... }:
{
  flake.homeModules.hexagonConfiguration =
    { pkgs, nixgl, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      imports = [
        (self.lib.gitModule {
          userName = "Manuel Strenge";
          userEmail = "manuel.strenge-ext@hexagon.com";
        })
        self.homeModules.devtools
        self.homeModules.console
        self.homeModules.info
        self.homeModules.dvt
        self.homeModules.dvd
        self.homeModules.wsswitch
        self.homeModules.tmux
        self.homeModules.nvimConfig
        self.homeModules.claude
        self.homeModules.timewarriorAuto
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
        keyboard = {
          options = [ "caps:escape" ];
        };
        packages = [
          pkgs.git-crypt
          pkgs.wl-clipboard
          pkgs.timewarrior
        ];
      };

      programs.home-manager.enable = true;
    };
}
