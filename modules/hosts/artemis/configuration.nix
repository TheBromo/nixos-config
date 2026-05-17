{ self, ... }:
{
  flake.nixosModules.artemisConfiguration =
    { config, pkgs, ... }:
    {
      imports = [
        self.nixosModules.base
        self.nixosModules.onePassword
        self.nixosModules.gnome
        self.nixosModules.fonts
        self.nixosModules.tailscale
        self.nixosModules.artemisHardware
        self.nixosModules.manuelUser
      ];

      nixpkgs.hostPlatform = "x86_64-linux";
      nixpkgs.config.allowUnfree = true;

      programs.nix-ld.enable = true;

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      networking.hostName = "artemis";
      networking.networkmanager.enable = true;

      time.timeZone = "Europe/Zurich";

      i18n.defaultLocale = "en_US.UTF-8";

      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      services.printing.enable = true;

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      programs.firefox.enable = true;

      environment.systemPackages = [
        pkgs.neovim
        pkgs.git
        pkgs.codex
      ];

      system.stateVersion = "26.05"; # Did you read the comment?

      hardware.graphics.enable = true;

      services.xserver.videoDrivers = [ "nvidia" ];
      services.displayManager.gdm.wayland = true;
      programs.xwayland.enable = true;
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "0";
      };

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
    };
}
