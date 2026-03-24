{ self, inputs, ... }:
{
  flake.homeModules.manuelDarwinConfiguration =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      imports = [
        self.homeModules.git
        self.homeModules.devtools
        self.homeModules.console
        self.homeModules.tmux
        self.homeModules.nvimConfig
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
    };
}
