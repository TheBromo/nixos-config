_: {
  flake.homeModules.mcp =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      grafanaTokenReference = "op://Employee/Grafana Service Account/credential";
      mcpSecretsDirectory = "${config.xdg.configHome}/mcp/secrets";
      grafanaTokenFile = "${mcpSecretsDirectory}/grafana-service-account-token";
      installMcpSecrets = pkgs.writeShellApplication {
        name = "install-mcp-secrets";
        text = ''
          if [[ ! -x /usr/bin/op ]]; then
            echo "install-mcp-secrets: /usr/bin/op is not available" >&2
            exit 127
          fi

          mkdir -p ${lib.escapeShellArg mcpSecretsDirectory}
          chmod 700 ${lib.escapeShellArg mcpSecretsDirectory}

          temporary_file=$(mktemp ${lib.escapeShellArg "${mcpSecretsDirectory}/.grafana-service-account-token.XXXXXX"})
          trap 'rm -f -- "$temporary_file"' EXIT

          /usr/bin/op read ${lib.escapeShellArg grafanaTokenReference} > "$temporary_file"
          chmod 600 "$temporary_file"
          mv -f "$temporary_file" ${lib.escapeShellArg grafanaTokenFile}
          trap - EXIT
        '';
      };
    in
    {
      programs = {
        mcp = {
          enable = true;
          servers.grafana = {
            command = lib.getExe' pkgs.uv "uvx";
            args = [ "mcp-grafana" ];
            env = {
              GRAFANA_URL = "https://grafana-d4cmdgcne4fdexh0.nch.grafana.azure.com";
              GRAFANA_SERVICE_ACCOUNT_TOKEN.file = grafanaTokenFile;
            };
          };
        };
        claude-code.enableMcpIntegration = true;
      };

      home.activation.installMcpSecrets = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${lib.getExe installMcpSecrets}
      '';
    };
}
