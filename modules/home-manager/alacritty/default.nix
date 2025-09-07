{
  pkgs,
  lib,
  ...
}:
let
  fontFamily = "BerkeleyMono Nerd Font"; # "GeistMono Nerd Font";
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";
      scrolling.history = 100000;
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
      };

      window = {
        decorations = "full";
        title = "Alacritty";
        dynamic_title = true;
        padding = {
          x = 0;
          y = 4;
        };
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };
      font = {
        size = 12.0;
        normal = {
          family = fontFamily;
          style = "Regular";
        };
        bold = {
          family = fontFamily;
          style = "Bold";
        };
        italic = {
          family = fontFamily;
          style = "Italic";
        };
        bold_italic = {
          family = fontFamily;
          style = "BoldItalic";
        };
      };
      colors = import ./theme.nix;
    };
  };

  fonts.fontconfig.enable = true;
}
