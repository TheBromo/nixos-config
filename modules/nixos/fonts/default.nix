{
  pkgs,
  self,
  ...

}:
let
  tx-02 = import "${self}/pkgs/TX-02" { inherit pkgs; };
in
{
  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-color-emoji
      pkgs.font-awesome
      tx-02
    ];
    fontconfig.defaultFonts = {
      serif = [
        "Noto Serif"
      ];
      sansSerif = [
        "Open Sans"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
