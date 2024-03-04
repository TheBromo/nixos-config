{ pkgs, root, ... }: {

  home.packages = with pkgs; [
    # wayland 
    dunst
    wl-clipboard
    shotman
    swaylock
    swayidle
    wofi
    glib
    gnome.nautilus
    waybar
    dconf
    pavucontrol
  ];

  programs.waybar = {
    enable = true;
    settings = import ./waybar/config.nix;
    style = ''
      ${builtins.readFile ./waybar/style.css} 
    '';
  };

  programs.wofi = {
    enable = true;
    style = ''
      ${builtins.readFile ./wofi/style.css} 
    '';
  };


  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      menu = "wofi --show run";
      bars = [{
        fonts.size = 12.0;
        command = "waybar"; # You can change it if you want
        position = "top";
      }];
      modifier = "Mod4"; # Super key
      terminal = "alacritty";
      output = {
        "eDP-2" = {
          mode = "2560x1600@120Hz";
        };
      };
    };
    extraConfig = ''
      bindsym Print               exec shotman -c output
      bindsym Print+Shift         exec shotman -c region
      bindsym Print+Shift+Control exec shotman -c window
      
      output * background /etc/wallpaper.png fill
     
      gaps inner 5
      gaps outer 5 
      default_border pixel 0 

      # Brightness
      bindsym XF86MonBrightnessDown exec light -U 10
      bindsym XF86MonBrightnessUp exec light -A 10

      # Volume
      bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'
      bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'
      bindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'
    '';
    extraSessionCommands = ''  
            export SDL_VIDEODRIVER=wayland  # needs qt5.qtwayland in systemPackages  
            export QT_QPA_PLATFORM=wayland  
            export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"  # Fix for some Java AWT applications (e.g. Android Studio),  
            # use this if they aren't displayed properly:   export _JAVA_AWT_WM_NONREPARENTING=1'';
  };

}
