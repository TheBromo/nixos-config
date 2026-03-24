{ self, inputs, ... }:
{
  flake.homeModules.claude =
    { config, ... }:
    {
      programs.claude-code = {
        enable = true;

        settings = {
          hasCompletedProjectOnboarding = true;
          hasCompletedOnboarding = true;

          env = {
            CLAUDE_CODE_ENABLE_TELEMETRY = "0";
            BASH_DEFAULT_TIMEOUT_MS = "300000";
          };

          permissions = {
            allow = [
              "Bash(nixf-diagnose *)"
              "Bash(git branch *)"
              "Bash(git diff *)"
              "Bash(git log *)"
              "Bash(git merge-base *)"
              "Bash(git status)"
              "Bash(glab *)"
              "Bash(just *)"
              "Bash(nix eval *)"
              "Bash(nix build *)"
              "Bash(nix-build *)"
              "Bash(nix-shell *)"
              "Bash(nixfmt *)"
              "Bash(pre-commit run *)"
              "Bash(statix *)"
              "Edit"
              "Glob"
              "Grep"
              "LS"
              "MultiEdit"
              "Read(:/nix/store)"
              "WebFetch(domain:docs.anthropic.com)"
              "WebFetch(domain:gohugo.io)"
              "WebFetch(domain:just.systems)"
              "WebFetch(domain:nixos.org)"
              "WebFetch(domain:nixos.wiki)"
              "WebSearch"
              "mcp__github__code"
              "mcp__github__list_pull_requests"
              "mcp__github__list_releases"
              "mcp__github__list_tags"
              "mcp__github__search_code"
              "mcp__github__search_issues"
              "mcp__github__search_pull_requests"
              "mcp__github__search_repositories"
              "mcp__mcp-pypi__*"
              "mcp__nixos__nixos_search"
              "mcp__rime__nix*"
              "mcp__rime__nixos*"
              "mcp__terraform*"
              "mcp__atlassian__getJiraIssue"
              "mcp__gitlab__*"
              "mcp__lattice__*"
              "mcp__jfrog__*"
              "mcp__sonarcloud__*"
              "Bash(jira issue view:*)"
              "mcp__dynamic-mcp__call_dynamic_tool"
              "mcp__dynamic-mcp__get_dynamic_tools"
              "Bash(dynamic-mcp:*)"
            ];
            deny = [
              "Bash(rm -rf *)"
              "Bash(curl *)"
              "Bash(sudo *)"
              "Bash(ls *)"
              "Bash(grep *)"
              "Bash(touch *)"
              "Read(.env)"
              "Read(.env.*)"
              "Read(secrets/**)"
              "Write(secrets/**)"
            ];
            ask = [
              "Bash(git push *)"
              "Bash(rm -f *)"
            ];
            defaultMode = "default";
          };

          model = "opus";
          hooks = {
            PreToolUse = [
              {
                matcher = "Read";
                hooks = [
                  {
                    type = "command";
                    command = "python3 ~/.claude/hooks/enforce-lattice.py";
                    timeout = 10;
                  }
                ];
              }
            ];
          };

          enabledMcpjsonServers = [
            # "dynamic-mcp" #TODO: correctly setup
            "atlassian"
            "terraform"
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

        mcpServers = {
          # dynamic-mcp = {
          #   type = "stdio";
          #   command = "dmcp";
          #   args = [ "${config.home.homeDirectory}/.config/dynamic-mcp/config.json" ];
          #   env = { };
          # };
          terraform = {
            command = "docker";
            args = [
              "run"
              "-i"
              "--rm"
              "hashicorp/terraform-mcp-server"
            ];
          };
          atlassian = {
            type = "http";
            url = "https://mcp.atlassian.com/v1/mcp";
          };
        };

        hooks = {
          "enforce-lattice.py" = builtins.readFile ./enforce-lattice.py;
        };
      };
    };
}
