{ pkgs, ... }: pkgs.stdenvNoCC.mkDerivation
{
  name = "TX-02";
  version = "2.002";
  src = ./../../secrets/TX-02.tar.xz;
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/opentype/ TX-02/*.otf
    install -Dm644 -t $out/share/fonts/truetype/ TX-02/*.ttf

    runHook postInstall
  '';
}
