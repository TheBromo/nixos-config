_: {
  flake.homeModules.mcp =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      mcpSecretsDirectory = "${config.xdg.configHome}/mcp/secrets";
      grafanaTokenFile = "${mcpSecretsDirectory}/grafana-service-account-token";
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
    };
}
