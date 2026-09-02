{ ... }:
{
  flake.homeModules.darwinTools =
    { config, pkgs, ... }:
    let
      dockerHost = "unix://${config.home.homeDirectory}/.docker/run/docker.sock";
      chipmindPython = pkgs.runCommand "chipmind-python" { } ''
        mkdir -p "$out/bin"
        ln -s ${pkgs.python312}/bin/python3.12 "$out/bin/python3.12"
      '';
      dockerCredentialDesktop = pkgs.writeShellScriptBin "docker-credential-desktop" ''
        exec /Applications/Docker.app/Contents/Resources/bin/docker-credential-desktop "$@"
      '';
    in
    {
      home = {
        sessionVariables.DOCKER_HOST = dockerHost;
        packages = [
          pkgs.awscli2
          pkgs.docker-client
          dockerCredentialDesktop
          pkgs.git-lfs
          pkgs.git-crypt
          pkgs.openvscode-server
          chipmindPython
          pkgs.poetry
        ];
      };

      # hm-session-vars.sh is deliberately sourced only once. After a Home
      # Manager switch, an existing terminal therefore retains its old
      # environment and Docker's Python SDK falls back to /var/run/docker.sock.
      # Refresh DOCKER_HOST whenever an interactive shell starts as well.
      programs = {
        bash.initExtra = ''
          export DOCKER_HOST=${dockerHost}
        '';
        zsh.initContent = ''
          export DOCKER_HOST=${dockerHost}
        '';
      };
    };
}
