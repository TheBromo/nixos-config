{ pkgs, root, ... }:
let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/dunst &
    
    ${pkgs.waybar}/bin/waybar &
    ${pkgs.swww}/bin/swww init &
  
    sleep 1
  
    ${pkgs.swww}/bin/swww img ${"/etc/wallpaper.jpg"} &
  '';
in
{
  imports = [
    ./waybar
    ./wofi
    ./mako
    ./swaylock
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      ${builtins.readFile ./hyprland.conf} 
    '';

    settings = {
      exec-once = ''
        ${startupScript}/bin/start
      '';
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    cursorTheme = {
      name = "macchiatoDark";
      package = pkgs.catppuccin-cursors;
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };
}
