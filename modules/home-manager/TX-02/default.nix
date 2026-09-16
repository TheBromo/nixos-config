# The font source lives in secrets/, git-crypt encrypted, because its licence
# does not permit publication and this repository is public. CI therefore never
# decrypts it: `custom.tx02.enable = false` drops the font from the closure that
# .github/workflows/build.yml builds and pushes to the public cache.
{ self, ... }:
{
  flake.homeModules.TX-02 =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      tx-02 = pkgs.stdenvNoCC.mkDerivation {
        name = "TX-02";
        version = "2.002";
        src = "${self}/secrets/TX-02.tar.xz";
        sourceRoot = ".";

        # Makes the font visible to the assertion in
        # modules/home-manager/non-redistributable.
        meta.license = lib.licenses.unfree // {
          redistributable = false;
        };

        installPhase = ''
          runHook preInstall

          install -Dm644 -t $out/share/fonts/opentype/ TX-02/*.otf
          install -Dm644 -t $out/share/fonts/truetype/ TX-02/*.ttf

          runHook postInstall
        '';
      };
    in
    {
      options.custom.tx02.enable = lib.mkEnableOption "the TX-02 font from secrets/" // {
        default = config.custom.nonRedistributable.enable;
      };

      config = lib.mkIf config.custom.tx02.enable {
        home.packages = [
          tx-02
        ];
      };
    };
}
