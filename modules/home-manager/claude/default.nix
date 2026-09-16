{ self, ... }:
{
  flake.homeModules.claude =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      llmAgents = self.lib.llmAgents pkgs;

      settings = {
        hasCompletedProjectOnboarding = true;
        hasCompletedOnboarding = true;

        env = {
          CLAUDE_CODE_ENABLE_TELEMETRY = "1";
          BASH_DEFAULT_TIMEOUT_MS = "300000";

          # Authenticate against Amazon Bedrock instead of the Anthropic API,
          # using the ambient AWS credentials (AWS_PROFILE from the console
          # module).
          CLAUDE_CODE_USE_BEDROCK = "1";
          AWS_REGION = "us-east-1";
        };

        permissions = {
          defaultMode = "bypassPermissions";
          skipDangerousModePermissionPrompt = true;
        };

        model = "opus[1m]";
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

      checkStrayAgents = pkgs.writeShellApplication {
        name = "check-stray-agent-binaries";
        text = ''
          for stray in \
            "$HOME/.local/bin/claude" \
            "$HOME/.local/share/claude" \
            "$HOME/.local/bin/codex" \
            "$HOME/.codex/packages"
          do
            if [[ -e "$stray" ]]; then
              echo "warning: $stray is left over from a native installer." >&2
              echo "         Whether it shadows the nix-provided binary depends on when" >&2
              echo "         /etc/zshrc re-prepends ~/.nix-profile/bin, so remove it once" >&2
              echo "         the nix-provided version has proven itself." >&2
            fi
          done
        '';
      };
    in
    {
      programs.claude-code = {
        enable = true;
        # meta.license.redistributable = false, so `null` is what keeps this out
        # of the CI closure. Not lib.mkIf: the option default is
        # pkgs.claude-code, which is equally non-redistributable, so a false
        # mkIf would silently swap one restricted binary for another.
        package = if config.custom.nonRedistributable.enable then llmAgents.claude-code else null;
        mcpServers.chrome-devtools = {
          command = lib.getExe' pkgs.nodejs_26 "npx";
          args = [
            "-y"
            "chrome-devtools-mcp@latest"
            "--isolated"
          ];
        };
      };

      home.activation.installClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${lib.getExe installClaudeSettings}
      '';

      # Warn only. The native installs must stay on disk during the trial period
      # so that a rollback still leaves a working claude.
      home.activation.checkStrayAgentBinaries = lib.hm.dag.entryAfter [ "installPackages" ] ''
        ${lib.getExe checkStrayAgents} || true
      '';

      # Never set programs.claude-code.skills to a path: home-manager would turn
      # ~/.claude/skills into a recursive home.file source, and
      # check-link-targets would then refuse to clobber the copies made below.
      home.activation.installClaudeSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.claude/skills"
        cp -rf --no-preserve=mode ${self.lib.mattpocockSkills pkgs}/. "$HOME/.claude/skills/"
        cp -rf --no-preserve=mode ${self.lib.dotagentsSkills pkgs}/. "$HOME/.claude/skills/"
        cp -rf --no-preserve=mode ${self.lib.ghStackSkill pkgs}/. "$HOME/.claude/skills/"
        cp -rf --no-preserve=mode ${self.lib.conventionalGitSkills pkgs}/. "$HOME/.claude/skills/"
        cp -rf --no-preserve=mode ${self.lib.chipmindDebugSkill pkgs}/. "$HOME/.claude/skills/"
        cp -rf --no-preserve=mode ${self.lib.reactDoctorSkill pkgs}/. "$HOME/.claude/skills/"
        cp -rf --no-preserve=mode ${self.lib.frontendDesignSkill pkgs}/. "$HOME/.claude/skills/"
      '';
    };
}
