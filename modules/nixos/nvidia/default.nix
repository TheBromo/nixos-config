{
  config,
  pkgs,
  ...
}:
{
  environment = {
    variables.LIBVA_DRIVER_NAME = "nvidia";
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  nixpkgs.config.cudaSupport = false;

  services.xserver.videoDrivers = [ "nvidia" ];
  boot.initrd.kernelModules = [ "nvidia" ];
  # NOTE: nvidia_x11 is handled automatically when using modern nvidia package
  # boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [
        pkgs.vaapiVdpau
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
