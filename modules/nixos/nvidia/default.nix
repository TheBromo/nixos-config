{ config, pkgs, ... }: {
  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
  };

  nixpkgs.config.cudaSupport = false;

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.initrd.kernelModules = [ "nvidia" ];
  #boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
      ];
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
