{ config, pkgs, ... }: {
  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
  };

  nixpkgs.config.cudaSupport = false;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;

      open = true;
      nvidiaSettings = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
