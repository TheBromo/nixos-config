{ ... }:
{
  flake.lib.ghStackSkill =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "github";
        repo = "gh-stack";
        rev = "fc2b03d34528917574b41d4d749a477263a6afc5";
        hash = "sha256-/TpZwsIvLczKzqCU+Ez/TGeGsXegUHSoQdXo/nLhC/o=";
      };
    in
    pkgs.runCommand "gh-stack-skill" { } ''
      mkdir -p $out
      cp -r ${src}/skills/gh-stack $out/gh-stack
    '';
}
