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
        exec = "${config.lib.nixGL.wrap pkgs.ghostty}/bin/ghostty";
        icon = "com.mitchellh.ghostty";
        terminal = false;
        type = "Application";
        categories = [
          "System"
          "TerminalEmulator"
        ];
      };

      programs.ghostty = {
        package = (config.lib.nixGL.wrap inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default);
        enable = true;
        enableZshIntegration = true;
        installVimSyntax = true;
        settings = {
          theme = "Builtin Pastel Dark";

          font-family = [
            "TX-02"
            "Apple Color Emoji"
          ];
          font-size = 12.5;
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
