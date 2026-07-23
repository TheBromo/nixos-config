{ self, lib, ... }:
{
  flake.homeModules.claude =
    { pkgs, lib, ... }:
    let
      settings = {
        "$schema" = "https://json.schemastore.org/claude-code-settings.json";
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
      settingsFile = builtins.toFile "claude-settings.json" ((builtins.toJSON settings) + "\n");
    in
    {
      home.activation.installClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        install -D -m 644 ${settingsFile} "$HOME/.claude/settings.json"
      '';

      home.activation.installClaudeSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.claude/skills"
        cp -rf --no-preserve=mode ${self.lib.mattpocockSkills pkgs}/. "$HOME/.claude/skills/"
        cp -rf --no-preserve=mode ${self.lib.dotagentsSkills pkgs}/. "$HOME/.claude/skills/"
      '';
    };
}
