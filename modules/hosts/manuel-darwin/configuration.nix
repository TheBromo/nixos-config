{ self, ... }:
{
  flake.homeModules.manuelDarwinConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      nixpkgs.config.allowUnfree = true;

      imports = [
        (self.lib.gitModule { })
        self.homeModules.nonRedistributable
        # Determinate Nix, user not in trusted-users: the caches live in
        # /etc/nix/nix.custom.conf via `make nix-conf` instead.
        (self.lib.nixSettingsModule { trustedUser = false; })
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
        self.homeModules.antigravity
        self.homeModules.opencode
        self.homeModules.pi
        self.homeModules.rex
        self.homeModules.t3code
        self.homeModules.info
        self.homeModules.dvt
        self.homeModules.dvd
        self.homeModules.wsswitch
        self.homeModules.terraform
        (self.lib.ghosttyModule { isDarwin = true; })
        self.homeModules.TX-02
        self.homeModules.nvimConfig
        self.homeModules.zedCyberdream
        self.homeModules.timewarrior
      ];

      home = {
        username = "manuel";
        homeDirectory = "/Users/manuel";
        stateVersion = "24.11";
        sessionVariables = {
          CC = "/usr/bin/cc";
          SHELL = lib.getExe pkgs.zsh;
        };
        file.".cargo/config.toml".text = ''
          [target.aarch64-apple-darwin]
          linker = "/usr/bin/cc"
        '';
      };

      programs.home-manager.enable = true;

      worktrees.directory = "/Volumes/Development/Worktrees";

      # Use the installer-managed Determinate client for this user's profiles.
      launchd.agents.nix-gc = {
        enable = true;
        config = {
          ProgramArguments = [
            "/nix/var/nix/profiles/default/bin/nix-collect-garbage"
            "--delete-older-than"
            "14d"
          ];
          StartCalendarInterval = [
            {
              Hour = 3;
              Minute = 15;
            }
          ];
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/nix-gc.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/nix-gc.log";
        };
      };
    };
}
