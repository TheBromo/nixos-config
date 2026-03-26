{ ... }:
{
  flake.lib.ghosttyModule =
    { isDarwin ? false }:
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
        themes.monokai-pro = {
          palette = [
            "0=#121212"
            "1=#ff6188"
            "2=#a9dc76"
            "3=#ffd866"
            "4=#fc9867"
            "5=#ab9df2"
            "6=#78dce8"
            "7=#fcfcfa"
            "8=#727072"
            "9=#ff6188"
            "10=#a9dc76"
            "11=#ffd866"
            "12=#fc9867"
            "13=#ab9df2"
            "14=#78dce8"
            "15=#fcfcfa"
          ];
          background = "#080808";
          foreground = "#fcfcfa";
          cursor-color = "#c1c0c0";
          cursor-text = "#8e8d8d";
          selection-background = "#5b595c";
          selection-foreground = "#fcfcfa";
        };
        settings = {
          theme = "monokai-pro";

          font-family = [
            "TX-02"
            "Fluent Emoji Color"
          ];
          font-size = 13;
          font-feature = "-calt, -liga, -dlig";

          shell-integration = "zsh";
          command = "zsh";

          macos-icon = "xray";

          keybind = [
          ];
        };
      };
    };
}
