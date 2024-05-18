{ pkgs, lib, ... }:
let
  fontFamily = "Berkeley Mono"; # "GeistMono Nerd Font";
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";
      scrolling.history = 100000;
      live_config_reload = true;

      window = {
        decorations = "full";
        title = "Alacritty";
        dynamic_title = true;
        padding = {
          x = 12;
          y = 2;
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

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "GeistMono" ]; })
  ];

  fonts.fontconfig.enable = true;

}
