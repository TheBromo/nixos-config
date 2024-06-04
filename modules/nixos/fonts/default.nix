{ pkgs, root, ... }:
let
  berkley = pkgs.stdenvNoCC.mkDerivation
    {
      name = "berkeley mono";
      version = "1.009";
      src = ./../../../secrets/berkeley-mono.zip;
      sourceRoot = ".";

      nativeBuildInputs = [
        pkgs.unzip
      ];

      installPhase = ''
        runHook preInstall

        install -Dm644 -t $out/share/fonts/truetype/ berkeley-mono/TTF/*.ttf
        install -Dm644 -t $out/share/fonts/opentype/ berkeley-mono/OTF/*.otf

        runHook postInstall
      '';
    };
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
      berkley
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Open Sans" "Source Han Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };


}
