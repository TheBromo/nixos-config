{ self, ... }:
{
  flake.homeModules.claude =
    { pkgs, lib, ... }:
    let
      settings = {
        hasCompletedProjectOnboarding = true;
        hasCompletedOnboarding = true;

        env = {
          CLAUDE_CODE_ENABLE_TELEMETRY = "1";
          BASH_DEFAULT_TIMEOUT_MS = "300000";
        };

        permissions = {
          defaultMode = "bypassPermissions";
          skipDangerousModePermissionPrompt = true;
        };

        model = "opus";
        extraKnownMarketplaces = {
          caveman = {
            source = {
              source = "github";
              repo = "JuliusBrussee/caveman";
            };
          };
        };

        enabledPlugins = {
          "code-review@claude-code-plugins" = true;
          "feature-dev@claude-code-plugins" = true;
          "frontend-design@claude-code-plugins" = true;
          "pr-review-toolkit@claude-code-plugins" = true;

          "caveman@caveman" = true;

          "security-guidance@claude-code-plugins" = true;

          "microsoft-docs@claude-plugins-official" = true;

          "basedpyright@claude-code-lsps" = true;
          "clangd@claude-code-lsps" = true;
          "pyright@claude-code-lsps" = true;
          "gopls-lsp@claude-code-lsps" = true;
          "lua-lsp@claude-code-lsps" = true;
        };
      };
      settingsFile = (pkgs.formats.json { }).generate "claude-settings.json" (
        settings
        // {
          "$schema" = "https://json.schemastore.org/claude-code-settings.json";
        }
      );
      installClaudeSettings = pkgs.writeShellApplication {
        name = "install-claude-settings";
        text = ''
          config_dir="''${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
          config_path="$config_dir/settings.json"
          mkdir -p "$config_dir"

          temporary_file=$(mktemp "$config_dir/.settings.json.XXXXXX")
          trap 'rm -f -- "$temporary_file"' EXIT

          if [[ -e "$config_path" ]]; then
            ${lib.getExe pkgs.jq} -s '.[0] * .[1]' \
              "$config_path" ${lib.escapeShellArg settingsFile} > "$temporary_file"
          else
            ${lib.getExe' pkgs.coreutils "cp"} ${lib.escapeShellArg settingsFile} "$temporary_file"
          fi

          chmod 600 "$temporary_file"
          mv -f "$temporary_file" "$config_path"
          trap - EXIT
        '';
      };
    in
    {
      programs.claude-code = {
        enable = true;
        package = null;
      };

      home.activation.installClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${lib.getExe installClaudeSettings}
      '';

      home.activation.installClaudeSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.claude/skills"
        cp -rf --no-preserve=mode ${self.lib.mattpocockSkills pkgs}/. "$HOME/.claude/skills/"
        cp -rf --no-preserve=mode ${self.lib.dotagentsSkills pkgs}/. "$HOME/.claude/skills/"
      '';
    };
}
