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
  ];

  # Bootloader.
  boot.loader ={
#    efi = {
#    	canTouchEfiVariables = true;
#    	efiSysMountPoint = "/boot/EFI"; # ← use the same mount point here.
#     };
     grub = {
	enable = true;
  	device = "nodev"; # for UEFI, set to the EFI system partition, e.g., "/dev/sda1"; for BIOS, set to "nodev"
  	efiSupport = true; # set to false if not using UEFI
	enableCryptodisk = true;# Add Fedora to the boot menu
	fontSize = 50;
#	useOSProber = true;
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

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # enables wireless support via wpa_supplicant.

  # configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noproxy = "127.0.0.1,localhost,internal.domain";

  # enable networking
  networking.networkmanager.enable = true;

  # set your time zone.
  time.timeZone = "Europe/Zurich";

  # select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # enable the x11 windowing system.
  services.xserver.enable = true;

  # enable the gnome desktop environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
 
  # configure keymap in x11
  services.xserver = {
    xkb.layout = "us";
  };

  # enable cups to print documents.
  services.printing.enable = true;

  # enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # if you want to use jack applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # enable touchpad support (enabled default in most desktopmanager).
  # services.xserver.libinput.enable = true;

   # allow unfree packages
  nixpkgs.config.allowunfree = true;

  # list packages installed in system profile. to search, run:
  # $ nix search wget 
  # This value determines the NixOS release from which the default settings for 
  # stateful data, like file locations and database versions on your system were 
  # taken. It's perfectly fine and recommended to leave this value at the release 
  # version of the first install of this system. Before changing this value read the 
  # documentation for this option (e.g. man configuration.nix or on 
  # https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  #environment = {
  #  shells = [ pkgs.zsh ];
  #};
}

