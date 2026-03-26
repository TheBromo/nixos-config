{ ... }:
{
  flake.homeModules.fluentui-emoji =
    { pkgs, ... }:
    let
      fluentui-emoji = pkgs.stdenvNoCC.mkDerivation {
        pname = "fluentui-emoji";
        version = "0.8.5";
        src = pkgs.fetchFromGitHub {
          owner = "tetunori";
          repo = "fluent-emoji-webfont";
          rev = "v0.8.5";
          hash = "sha256-HqnTMMW6YW8g956q0zEZCyoROr6MruRqgET2jfnlqFg=";
        };

        installPhase = ''
          runHook preInstall

          install -Dm644 -t $out/share/fonts/truetype/ dist/*.ttf

          runHook postInstall
        '';

        meta = {
          description = "Fluent Emoji Color font built from Microsoft's Fluent UI Emoji";
          homepage = "https://github.com/tetunori/fluent-emoji-webfont";
          license = pkgs.lib.licenses.mit;
        };
      };
    in
    {
      home.packages = [
        fluentui-emoji
      ];
    };
}
