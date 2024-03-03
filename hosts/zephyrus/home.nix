{ config, pkgs, inputs, root, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "manuel";
  home.homeDirectory = "/home/manuel";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    #apps
    alacritty
    firefox
    jetbrains.idea-ultimate

    #devtools
    jdk17
    rustc
    cargo
    rustfmt
    clippy
    git
    gcc
    go-task
    nixpkgs-fmt
    go
    gopls
    gotools

    #cli tools
    eza
    fzf
    starship
    bash
    nerdfonts

    # wayland 
    mako
    wl-clipboard
    shotman
    swaylock
    swayidle
    wofi
    glib
    gnome.nautilus
    waybar


  ];

  programs.git-credential-oauth.enable = true;

  programs.git = {
    enable = true;
    userName = "thebromo";
    userEmail = "manuel@strenge.ch";
  };

  programs.eza = {
    enable = true;
    enableAliases = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
    git = true;
    icons = true;
  };

  programs.fzf = {
    enable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";
      window = {
        decorations = "full";
        title = "Alacritty";
        dynamic_title = true;
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };
      font = {
        size = 12.0;
        normal.family = "GeistMono Nerd Font";
        bold.family = "GeistMono Nerd Font";
        italic.family = "GeistMono Nerd Font";
      };
    };
  };

  programs.fzf.enableBashIntegration = true;
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shortcut = "a";
    terminal = "screen-256color";
    clock24 = true;
  };


  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = rec {
      menu = "wofi --show run";
      bars = [{
        fonts.size = 15.0;
        command = "waybar"; # You can change it if you want
        position = "bottom";
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

  home.file = {
    #".config/nvim".source = "${neovimConfigRepo}/";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/nixos/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
