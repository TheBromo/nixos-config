{ ... }:
{
  flake.homeModules.claude =
    { pkgs, ... }:
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
    in
    {

      home.file.".claude/settings.json".text = (builtins.toJSON settings) + "\n";
    };
}
