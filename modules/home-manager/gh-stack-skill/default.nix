{ ... }:
{
  flake.lib.ghStackSkill =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "github";
        repo = "gh-stack";
        rev = "2bd699a544a09cb5c45a013d03416e0894b0454e";
        hash = "sha256-jwfqiCnCOOW0AKA52hbgvCCoLzfFX+QfM+vXABkzZgw=";
      };
    in
    pkgs.runCommand "gh-stack-skill" { } ''
      mkdir -p $out
      cp -r ${src}/skills/gh-stack $out/gh-stack
    '';
}
