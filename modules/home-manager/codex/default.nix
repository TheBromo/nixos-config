{ self, ... }:
{
  flake.homeModules.codex =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      baseSettings = {
        model = "gpt-5.6-sol";
        model_reasoning_effort = "medium";
        approval_policy = "never";
        sandbox_mode = "danger-full-access";

        tool_output_token_limit = 25000;
        # Leave room for native compaction near the 272–273k context window.
        # Formula: 273000 - (tool_output_token_limit + 15000)
        # With tool_output_token_limit=25000 ⇒ 273000 - (25000 + 15000) = 233000
        model_auto_compact_token_limit = 233000;

        features = {
          ghost_commit = false;
          hooks = true;
          unified_exec = true;
          plugins = true;
          skills = true;
          shell_snapshot = true;
        };

        marketplaces = {
          caveman-repo = {
            last_updated = "2026-04-24T14:28:50Z";
            last_revision = "84cc3c14fa1e10182adaced856e003406ccd250d";
            source_type = "git";
            source = "https://github.com/JuliusBrussee/caveman.git";
          };
          openai-bundled = {
            last_updated = "2026-04-24T14:32:32Z";
            source_type = "local";
            source = "/Users/manuel/.codex/.tmp/bundled-marketplaces/openai-bundled";
          };
        };

        projects = {
          "/home/strenge/Development".trust_level = "trusted";
          "/home/strenge/.config/nvim".trust_level = "trusted";
          "/Users/manuel/Development".trust_level = "trusted";
          "/Users/manuel/Development/nixos-config".trust_level = "trusted";
          "/Users/manuel/Development/caveman".trust_level = "trusted";
        };

        hooks.state = {
          "/home/strenge/.codex/hooks.json:session_start:0:0".trusted_hash =
            "sha256:bcf9397a6a66095da2fd157b8bf4949f51db7169f205a9b854c1fa9e27efcf92";
          "/Users/manuel/.codex/hooks.json:session_start:0:0".trusted_hash =
            "sha256:eddb0845a0762a0214ac8b2039f6636d3ced0654966a4586511e031cf1278509";
        };

        mcp_servers.swiss_caselaw = {
          enabled = true;
          url = "https://mcp.opencaselaw.ch/sse";
        };

        plugins = {
          "caveman@caveman-repo".enabled = true;
          "browser-use@openai-bundled".enabled = true;
        };
      };

      sharedMcpServers = lib.optionalAttrs config.programs.mcp.enable (
        lib.mapAttrs (
          name: server:
          lib.hm.mcp.transformMcpServer {
            inherit server;
            exclude = [
              "headers"
              "type"
            ];
            extraTransforms = [
              (
                transformed:
                transformed
                // lib.optionalAttrs (transformed.headers or { } != { }) {
                  http_headers = transformed.headers;
                }
              )
              lib.hm.mcp.addType
              (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; })
            ];
          }
        ) config.programs.mcp.servers
      );

      settings = baseSettings // {
        mcp_servers = sharedMcpServers // baseSettings.mcp_servers;
      };
      configFile = (pkgs.formats.toml { }).generate "codex-config.toml" settings;
      installCodexConfig = pkgs.writeShellApplication {
        name = "install-codex-config";
        text = ''
          config_dir="''${CODEX_HOME:-$HOME/.codex}"
          config_path="$config_dir/config.toml"
          mkdir -p "$config_dir"

          temporary_file=$(mktemp "$config_dir/.config.toml.XXXXXX")
          trap 'rm -f -- "$temporary_file"' EXIT

          if [[ -e "$config_path" ]]; then
            # The dollar-prefixed names below belong to yq, not the shell.
            # shellcheck disable=SC2016
            ${lib.getExe pkgs.yq-go} eval-all --input-format toml --output-format toml \
              'select(fileIndex == 0) as $existing | select(fileIndex == 1) as $desired | ($existing * $desired) | .mcp_servers = $desired.mcp_servers' \
              "$config_path" ${lib.escapeShellArg configFile} > "$temporary_file"
          else
            ${lib.getExe' pkgs.coreutils "cp"} ${lib.escapeShellArg configFile} "$temporary_file"
          fi

          chmod 600 "$temporary_file"
          mv -f "$temporary_file" "$config_path"
          trap - EXIT
        '';
      };
    in
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      home = {
        packages = [ pkgs.codex ];
        activation = {
          installCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            ${lib.getExe installCodexConfig}
          '';
          installCodexSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p "$HOME/.codex/skills"
            cp -rf --no-preserve=mode ${self.lib.mattpocockSkills pkgs}/. "$HOME/.codex/skills/"
            cp -rf --no-preserve=mode ${self.lib.dotagentsSkills pkgs}/. "$HOME/.codex/skills/"
          '';
        };
      };
    };
}
