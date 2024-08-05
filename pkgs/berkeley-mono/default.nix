{ pkgs, ... }: pkgs.stdenvNoCC.mkDerivation
{
  name = "berkeley mono";
  version = "1.009";
  src = ./../../secrets/berkeley-mono.zip;
  sourceRoot = ".";

  nativeBuildInputs = [
    pkgs.unzip
    pkgs.nerd-font-patcher
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p patched/TTF
    mkdir -p patched/OTF

    # Patch each TTF file with Nerd Font Patcher
    for font in berkeley-mono/TTF/*.ttf; do
      nerd-font-patcher --complete --quiet --out patched/TTF "$font"
    done

    # Patch each OTF file with Nerd Font Patcher
    for font in berkeley-mono/OTF/*.otf; do
      nerd-font-patcher --complete --quiet --out patched/OTF "$font"
    done

    install -Dm644 -t $out/share/fonts/truetype/ patched/TTF/*.ttf
    install -Dm644 -t $out/share/fonts/opentype/ patched/OTF/*.otf

    runHook postInstall
  '';
}
