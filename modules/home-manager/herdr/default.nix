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
            overlay0 = "#6b7078";
            overlay1 = "#ffffff";
            panel_bg = "#16181a";
            peach = "#ffbd5e";
            red = "#ff6e5e";
            subtext0 = "#ffffff";
            surface0 = "#3c4048";
            surface1 = "#3c4048";
            surface_dim = "#16181a";
            teal = "#5ef1ff";
            text = "#ffffff";
            yellow = "#f1ff5e";
          };
        };
        ui.agent_panel_sort = "spaces";
      };
    in
    {
      xdg.configFile."herdr/config.toml".source = herdrConfig;

      home = {
        packages = [
          herdr
          pkgs.python3
        ];

        activation = {
          installHerdrIntegrations =
            lib.hm.dag.entryAfter
              [
                "installClaudeSettings"
                "installCodexConfig"
              ]
              ''
                ${lib.getExe herdr} integration install opencode
                ${lib.getExe herdr} integration install pi
                ${lib.getExe herdr} integration install claude
                ${lib.getExe herdr} integration install codex
              '';
        };
      };
    };
}
