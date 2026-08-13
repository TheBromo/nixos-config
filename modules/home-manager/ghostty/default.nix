{ ... }:
{
  flake.lib.ghosttyModule =
    {
      isDarwin ? false,
    }:
    {
      config,
      pkgs,
      inputs,
      lib,
      ...
    }:
    {
      xdg.desktopEntries = lib.mkIf (!isDarwin) {
        ghostty = {
          name = "Ghostty";
          genericName = "Terminal Emulator";
          exec = "${
            config.lib.nixGL.wrap inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
          }/bin/ghostty";
          icon = "${
            inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
          }/share/icons/hicolor/256x256/apps/com.mitchellh.ghostty.png";
          terminal = false;
          type = "Application";
          categories = [
            "System"
            "TerminalEmulator"
          ];
          settings.StartupWMClass = "com.mitchellh.ghostty";
        };
      };

      home.activation.linkGhosttyConfig = lib.mkIf isDarwin (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
          mkdir -p "$ghostty_dir"
          if [ ! -L "$ghostty_dir/config" ]; then
            rm -f "$ghostty_dir/config"
          fi
          ln -sf "$HOME/.config/ghostty/config" "$ghostty_dir/config"

          # Link custom themes
          if [ -d "$HOME/.config/ghostty/themes" ]; then
            if [ ! -L "$ghostty_dir/themes" ]; then
              rm -rf "$ghostty_dir/themes"
            fi
            ln -sf "$HOME/.config/ghostty/themes" "$ghostty_dir/themes"
          fi
        ''
      );

      programs.ghostty = {
        package =
          if isDarwin then
            null
          else
            (config.lib.nixGL.wrap inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default);
        enable = true;
        enableZshIntegration = true;
        themes.cyberdream = {
          palette = [
            "0=#080808"
            "1=#ff6e5e"
            "2=#5eff6c"
            "3=#f1ff5e"
            "4=#5ea1ff"
            "5=#bd5eff"
            "6=#5ef1ff"
            "7=#ffffff"
            "8=#6b7078"
            "9=#ff6e5e"
            "10=#5eff6c"
            "11=#f1ff5e"
            "12=#5ea1ff"
            "13=#bd5eff"
            "14=#5ef1ff"
            "15=#ffffff"
          ];
          background = "#080808";
          foreground = "#fcfcfa";
          cursor-color = "#c1c0c0";
          cursor-text = "#8e8d8d";
          selection-background = "#5b595c";
          selection-foreground = "#fcfcfa";
        };
        settings = {
          theme = "cyberdream";

          font-family = [
            "TX-02"
            "Fluent Emoji Color"
          ];
          font-style = "Light";

          font-family-bold = "TX-02";
          font-style-bold = "Bold";

          font-size = 13;
          font-feature = "-calt, -liga, -dlig";
          adjust-underline-position = 2;
          adjust-underline-thickness = "7%";

          window-padding-x = "2,0";
          window-padding-y = "2,0";

          shell-integration = "zsh";
          command = "zsh";

          macos-icon = "xray";

          keybind = [
          ];
        }
        // lib.optionalAttrs isDarwin {
          macos-titlebar-style = "tabs";
        };
      };
    };
}
