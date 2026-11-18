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

      worktreeCreate = pkgs.writeShellApplication {
        name = "claude-worktree-create";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.git
          pkgs.jq
        ];
        text =
          builtins.replaceStrings
            [ "@worktree_root@" ]
            [
              config.worktrees.directory
            ]
            (builtins.readFile ./worktree-create.sh);
      };

      settings = {
        hasCompletedProjectOnboarding = true;
        hasCompletedOnboarding = true;

        env = {
          # The Nix wrapper defaults to system-only, which misses public CAs on macOS.
          CLAUDE_CODE_CERT_STORE = "bundled,system";
          CLAUDE_CODE_ENABLE_TELEMETRY = "1";
          BASH_DEFAULT_TIMEOUT_MS = "300000";
        };

        permissions = {
          defaultMode = "bypassPermissions";
          skipDangerousModePermissionPrompt = true;
        };

        model = "opus[1m]";

        hooks.WorktreeCreate = [
          {
            hooks = [
              {
                type = "command";
                command = lib.getExe worktreeCreate;
              }
            ];
          }
        ];

        enabledPlugins = {
          "code-review@claude-code-plugins" = true;
          "feature-dev@claude-code-plugins" = true;
          "frontend-design@claude-code-plugins" = true;
          "pr-review-toolkit@claude-code-plugins" = true;

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
            # Caveman used to be a plugin; the plain merge would keep it enabled.
            # Remove the previous Bedrock environment overrides on activation.
            ${lib.getExe pkgs.jq} -s '.[0] * .[1] | del(.enabledPlugins."caveman@caveman") | del(.extraKnownMarketplaces.caveman) | del(.env.CLAUDE_CODE_USE_BEDROCK, .env.AWS_REGION)' \
              "$config_path" ${lib.escapeShellArg settingsFile} > "$temporary_file"
          else
            ${lib.getExe' pkgs.coreutils "cp"} ${lib.escapeShellArg settingsFile} "$temporary_file"
          fi

          chmod 600 "$temporary_file"
          mv -f "$temporary_file" "$config_path"
          trap - EXIT
        '';
      };

      # Red-orange look for claude_api, so an API-billed session can't pass
      # for a subscription one. Overrides the mascot/spinner and prompt border
      # of the dark-ansi theme the regular claude uses.
      apiThemeSlug = "claude-api";
      apiTheme = {
        name = "Claude API (Bedrock)";
        base = "dark-ansi";
        overrides = {
          claude = "rgb(235,64,40)";
          claudeShimmer = "rgb(255,120,95)";
          clawd_body = "rgb(235,64,40)";
          promptBorder = "rgb(205,70,45)";
          promptBorderShimmer = "rgb(245,120,95)";
        };
      };

      apiStatusLine = pkgs.writeShellApplication {
        name = "claude-api-statusline";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          model=$(jq -r '.model.display_name // empty')
          printf '\033[1;38;2;235;64;40m⚡ API · Bedrock\033[0m'
          if [[ -n "$model" ]]; then
            printf ' \033[2m%s\033[0m' "$model"
          fi
        '';
      };

      # Layered on top of settings.json for claude_api only.
      apiSettingsFile = (pkgs.formats.json { }).generate "claude-api-settings.json" {
        theme = "custom:${apiThemeSlug}";
        statusLine = {
          type = "command";
          command = lib.getExe apiStatusLine;
        };
      };

      # Runs claude against Amazon Bedrock instead of the subscription, using
      # the ambient AWS credentials (AWS_PROFILE from the console module).
      # Environment and --settings only, so it shares ~/.claude with the
      # regular claude.
      claudeApi = pkgs.writeShellApplication {
        # <harness>_api: the API-billed variant (codex has codex_api).
        name = "claude_api";
        text = ''
          export CLAUDE_CODE_USE_BEDROCK=1
          export AWS_REGION="''${AWS_REGION:-us-east-1}"
          exec ${lib.getExe config.programs.claude-code.finalPackage} --settings ${apiSettingsFile} "$@"
        '';
      };

      checkStrayAgents = pkgs.writeShellApplication {
        name = "check-stray-agent-binaries";
        text = ''
          for stray in \
            "$HOME/.local/bin/claude" \
            "$HOME/.local/share/claude" \
            "$HOME/.local/bin/codex" \
            "$HOME/.codex/packages" \
            "$HOME/.opencode/bin"
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
        mcpServers.superlogical = {
          type = "http";
          url = "https://www.superlogical.com/rex/community-mcp";
        };
      };

      home.packages = lib.mkIf (config.programs.claude-code.package != null) [ claudeApi ];

      # Custom themes are read from ~/.claude/themes/<slug>.json.
      home.file.".claude/themes/${apiThemeSlug}.json".source =
        (pkgs.formats.json { }).generate "${apiThemeSlug}-theme.json" apiTheme;

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
        rm -rf "$HOME/.claude/skills/cavecrew"
        cp -rf --no-preserve=mode ${self.lib.agentSkills pkgs}/. "$HOME/.claude/skills/"
      '';
    };
}
