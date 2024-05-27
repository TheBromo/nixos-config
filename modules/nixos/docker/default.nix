{ pkgs, ... }: {
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
