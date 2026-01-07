{ pkgs, ... }:
{
  home.packages = [
    pkgs.wofi
  ];

  programs.wofi = {
    enable = true;
    style = ''
      ${builtins.readFile ./wofi/style.css}
    '';
  };
}
