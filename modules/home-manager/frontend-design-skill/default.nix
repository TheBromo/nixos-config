{ ... }:
{
  flake.lib.frontendDesignSkill =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "anthropics";
        repo = "claude-code";
        rev = "e62465d553ecbf1697219ffbb3c11b4fef14d5bf";
        hash = "sha256-WmB2m1ZRmV8eB4iu+LNY7q5y2r/ecOR8WQzs/umhR3Y=";
      };
    in
    pkgs.runCommand "frontend-design-skill" { } ''
      mkdir -p $out
      cp -r ${src}/plugins/frontend-design/skills/frontend-design $out/frontend-design
    '';
}
