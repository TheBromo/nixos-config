{ pkgs, ... }: pkgs.stdenvNoCC.mkDerivation
{
  name = "berkeley mono";
  version = "1.009";
  src = ./../../secrets/berkeley-mono.zip;
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
