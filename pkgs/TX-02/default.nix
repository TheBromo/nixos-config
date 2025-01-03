{ pkgs, ... }: pkgs.stdenvNoCC.mkDerivation
{
  name = "TX-02";
  version = "1.1.0";
  src = ./../../secrets/TX-02.tar.xz;
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/opentype/ TX-02/*.otf

    runHook postInstall
  '';
}
