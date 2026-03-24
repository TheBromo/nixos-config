{ self, inputs, ... }:
{
  flake.homeModules.manuelConfiguration =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      imports = [
        self.homeModules.git
        self.homeModules.devtools
        self.homeModules.console
        self.homeModules.tmux
        self.homeModules.nvimConfig
        self.homeModules.ghostty
        self.homeModules.claude
      ];

      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/interface".color-scheme = "prefer-dark";
          "org/gnome/desktop/input-sources".xkb-options = [ "caps:escape" ];
        };
      };

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
