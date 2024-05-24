{ pkgs, ... }: {
  virtualisation.docker.enable = true;

  environment.systempackages = with pkgs; [
    docker-compose
  ];

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
