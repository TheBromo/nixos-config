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
      ];

      system.stateVersion = "25.05";

      hardware.graphics.enable = true;

      services.xserver.videoDrivers = [ "nvidia" ];

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
