{ pkgs, home-manager, inputs, root, ... }: {

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [ "vboxusers" "networkmanager" "wheel" "video" "wireshark" ];
    initialPassword = "changeme";
    packages = with pkgs; [
      firefox
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
      nerdfonts
      wireshark
      google-chrome
      jdk17
      glibc
      cmake
      gnumake

    ];
    shell = pkgs.bash;
  };
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

  environment = {
    sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    sessionVariables.NIXOS_OZONE_WL = "1";

    etc."wallpaper.jpg".source = (root + "/wallpaper.jpg");
    systemPackages = with pkgs; [
      grim
      swww
      #     hyprpicker.packages.${system}.default
      lxqt.lxqt-policykit
      slurp
      swaylock
      wl-clipboard
      # Required if applications are having trouble opening links
      xdg-utils
      xfce.thunar
      xfce.tumbler
      overskride
    ];
  };

  programs.wireshark.enable = true;
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  programs.dconf.enable = true;
  services.gnome = { gnome-keyring.enable = true; };
  services.gvfs.enable = true;

  # Unlock with Swaylock
  security = {
    pam = {
      services = {
        login.enableGnomeKeyring = true;
        swaylock = {
          fprintAuth = false;
          text = ''
            auth include login
          '';
        };
      };
    };
  };



  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [ "xdph" "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
        };
      };
    };
  };

  #  environment.variables.XCURSOR_SIZE = "16";
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.manuel = ({ ... }: {
      imports = [
        (root + "/modules/home-manager/git")
        (root + "/modules/home-manager/alacritty")
        (root + "/modules/home-manager/devtools")
        (root + "/modules/home-manager/hyprland")
        (root + "/modules/home-manager/console")
        (root + "/modules/home-manager/tmux")
      ];
      home = {
        stateVersion = "23.11";
        pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          name = "Simp1e Dark";

          package = pkgs.simp1e-cursors;

          size = 16;
        };
      };
    });
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}


