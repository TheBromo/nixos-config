# Edit this configuration file to define what should be installed on your system. 
# Help is available in the configuration.nix(5) man page, on 
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository: 
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, inputs, root, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (root + "/modules/nixos/base")
    ./user/manuel
    (root + "/modules/nixos/login")
  ];
  nixpkgs.config.permittedInsecurePackages = [
    "nix-2.16.2"
  ];
  # Bootloader.
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev"; # for UEFI, set to the EFI system partition, e.g., "/dev/sda1"; for BIOS, set to "nodev"
      efiSupport = true; # set to false if not using UEFI
      enableCryptodisk = true; # Add Fedora to the boot menu
      extraEntries = ''
            	menuentry "Fedora" {
              		set root=(hd0,1) 
        		chainloader /EFI/fedora/grubx64.efi
            	}
        	menuentry "Windows" {
        		set root=(hd0,1)
        		chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        	}
          	'';
    };
  };

  networking.hostName = "nixos-manuel"; # Define your hostname.
  # networking.wireless.enable = true;  # enables wireless support via wpa_supplicant.

  # configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noproxy = "127.0.0.1,localhost,internal.domain";

  # enable networking
  networking.networkmanager.enable = true;

  # set your time zone.
  time = {
    timeZone = "Europe/Zurich";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    supportedLocales = [ "en_US.UTF-8/UTF-8" "de_CH.UTF-8/UTF-8" ];
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_NUMERIC = "de_CH.UTF-8";
      LC_TIME = "de_CH.UTF-8";
      LC_MONETARY = "de_CH.UTF-8";
      LC_MEASUREMENT = "de_CH.UTF-8";
    };
  };
  services.xserver = {
    layout = "ch";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "sg";


  documentation = {
    enable = true;
    dev.enable = true;
    man.enable = true;
  };

  # wayland-related
  security.polkit.enable = true;
  programs.gnupg.agent.enable = true;
  hardware.opengl.enable = true; # when using QEMU KVM

  # enable cups to print documents.
  services.printing.enable = true;

  # enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # if you want to use jack applications, uncomment this
    #jack.enable = true;
    wireplumber.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # enable touchpad support (enabled default in most desktopmanager).
  # services.xserver.libinput.enable = true;

  # $ nix search wget 
  # This value determines the NixOS release from which the default settings for 
  # stateful data, like file locations and database versions on your system were 
  # taken. It's perfectly fine and recommended to leave this value at the release 
  # version of the first install of this system. Before changing this value read the 
  # documentation for this option (e.g. man configuration.nix or on 
  # https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      source-han-sans
      open-sans
      source-han-sans-japanese
      source-han-serif-japanese
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Open Sans" "Source Han Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  programs.light.enable = true;
}

