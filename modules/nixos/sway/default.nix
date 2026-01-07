{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = [
    pkgs.shotman
    pkgs.clipcat # wl-copy and wl-paste for copy/paste from stdin / stdout
    pkgs.mako # notification system developed by swaywm maintainer
  ];

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;
  services.xserver.enable = true;

  services.xserver.displayManager.sddm.enable = false;

  services.xserver.windowManager.sway = {
    enable = true;
    package = pkgs.sway;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;

    config = rec {
      modifier = "Mod4"; # Super key
      output = {
        "DP-4" = {
          mode = "1920x1080@160Hz";
          pos = "0 0";
        };
        "HDMI-0" = {
          mode = "1920x1080@120Hz";
          pos = "1920 0";
        };
      };
    };
    extraConfig = ''
      bindsym Print               exec shotman -c output
      bindsym Print+Shift         exec shotman -c region
      bindsym Print+Shift+Control exec shotman -c window
    '';
  };

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };

  # Enable rofi (a dmenu replacement)
  programs.rofi.enable = true;

  # Enable swaylock and swayidle
  services.swaylock.enable = true;
  services.swayidle.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu \
          --cmd sway
      '';
    };
  };

  environment.etc."greetd/environments".text = ''
    sway
  '';
}
