{ ... }:
{
  flake.homeModules.ghostty =
    {
      config,
      pkgs,
      inputs,
      ...
    }:
    {
      xdg.desktopEntries.ghostty = {
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

      programs.ghostty = {
        package = (
          config.lib.nixGL.wrap inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
        );
        enable = true;
        enableZshIntegration = true;
        installVimSyntax = true;
        settings = {
          theme = "Builtin Pastel Dark";

          font-family = [
            "TX-02"
            "Apple Color Emoji"
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
