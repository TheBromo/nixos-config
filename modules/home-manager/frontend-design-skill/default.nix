{ ... }:
{
  flake.lib.frontendDesignSkill =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "anthropics";
        repo = "claude-code";
        rev = "e47cc82bdbd27b5f799acd5b05fd0c29d33bb48c";
        hash = "sha256-sjF2i7gu2cDCz1jCLpvQeoV2VCNqpkKETZutQeW1DPo=";
      };
    in
    pkgs.runCommand "frontend-design-skill" { } ''
      mkdir -p $out
      cp -r ${src}/plugins/frontend-design/skills/frontend-design $out/frontend-design
    '';
}
