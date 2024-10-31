{ pkgs, root, ... }:
let
  berkeley = import "${root}/pkgs/berkeley-mono" { inherit pkgs; };
in
{

  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-emoji
      pkgs.font-awesome
      pkgs.source-han-sans
      pkgs.open-sans
      pkgs.source-han-sans-japanese
      pkgs.source-han-serif-japanese
      berkeley
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Open Sans" "Source Han Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
