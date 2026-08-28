_: {
  flake.homeModules.herdr =
    {
      inputs,
      lib,
      pkgs,
      ...
    }:
    let
      herdr = inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default;
      toml = pkgs.formats.toml { };
      herdrConfig = toml.generate "herdr-config.toml" {
        experimental.kitty_graphics = true;
        keys = {
          new_worktree = "prefix+shift+g";
          next_tab = "prefix+p";
          prefix = "ctrl+space";
          previous_tab = "prefix+n";
        };
        terminal.default_shell = lib.getExe pkgs.zsh;
        theme = {
          name = "terminal";
          custom = {
            accent = "#ffbd5e";
            blue = "#5ea1ff";
            green = "#5eff6c";
            mauve = "#bd5eff";
            overlay0 = "#8e8d8d";
            overlay1 = "#c1c0c0";
            panel_bg = "#080808";
            peach = "#ffbd5e";
            red = "#ff6e5e";
            subtext0 = "#c1c0c0";
            surface0 = "#5b595c";
            surface1 = "#5b595c";
            surface_dim = "#080808";
            teal = "#5ef1ff";
            text = "#fcfcfa";
            yellow = "#f1ff5e";
          };
        };
        ui.agent_panel_sort = "spaces";
      };
      installHerdrIntegrations = pkgs.writeShellApplication {
        name = "install-herdr-integrations";
        runtimeInputs = [
          herdr
          pkgs.coreutils
        ];
        text = builtins.readFile ./install-herdr-integrations.sh;
      };
    in
    {
      xdg.configFile."herdr/config.toml".source = herdrConfig;

      home = {
        packages = [
          herdr
          pkgs.pi-coding-agent
          pkgs.python3
        ];

        activation = {
          installHerdrIntegrations =
            lib.hm.dag.entryAfter
              [
                "installPackages"
                "installClaudeSettings"
                "installCodexConfig"
              ]
              ''
                ${lib.getExe installHerdrIntegrations}
              '';
        };
      };
    };
}
