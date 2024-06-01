{ pkgs, root, ... }:
let
  berkley-path = (root + "/secrets/berkeley-mono.zip");
in
{

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      source-han-sans
      open-sans
      source-han-sans-japanese
      source-han-serif-japanese
      (stdenv.mkDerivation {
        name = "berkley-mono";
        src = berkley-path;

        buildInputs = [ unzip ];
        unpackPhase = "unzip $src -d $out";
        installPhase = ''
          mkdir -p $out/share/fonts
          mv * $out/share/fonts/
        '';
      })
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Open Sans" "Source Han Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };


}
