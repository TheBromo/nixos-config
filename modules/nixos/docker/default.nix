{ pkgs, ... }:
{
  virtualisation.docker.enable = true;

  environment.systemPackages = [
    pkgs.docker-compose
  ];

  # TODO: Consider enabling rootless Docker for improved security
  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  # };
}
