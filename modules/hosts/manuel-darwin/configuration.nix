{ self, ... }:
{
  flake.homeModules.manuelDarwinConfiguration =
    { pkgs, ... }:
    let
      chipmindPython = pkgs.runCommand "chipmind-python" { } ''
        mkdir -p "$out/bin"
        ln -s ${pkgs.python312}/bin/python3.12 "$out/bin/python3.12"
      '';
      dockerCredentialDesktop = pkgs.writeShellScriptBin "docker-credential-desktop" ''
        exec /Applications/Docker.app/Contents/Resources/bin/docker-credential-desktop "$@"
      '';
    in
    {
      nixpkgs.config.allowUnfree = true;

      imports = [
        (self.lib.gitModule { })
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
        packages = [
          pkgs.docker-client
          dockerCredentialDesktop
          pkgs.git-lfs
          pkgs.git-crypt
          pkgs.openvscode-server
          chipmindPython
          pkgs.poetry
        ];
      };

      programs.home-manager.enable = true;
    };
}
