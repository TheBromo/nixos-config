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
        keys = {
          new_worktree = "prefix+shift+g";
          next_tab = "prefix+p";
          prefix = "ctrl+a";
          previous_tab = "prefix+n";
        };
        terminal.default_shell = lib.getExe pkgs.zsh;
        theme.name = "vesper";
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
