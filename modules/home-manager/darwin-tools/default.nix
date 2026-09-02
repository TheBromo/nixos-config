{ ... }:
{
  flake.homeModules.darwinTools =
    { pkgs, ... }:
    let
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
        sessionVariables.DOCKER_HOST = "unix:///Users/manuel/.docker/run/docker.sock";
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
    };
}
