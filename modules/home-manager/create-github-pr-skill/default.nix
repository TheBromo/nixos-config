{ ... }:
{
  flake.lib.createGithubPrSkill =
    pkgs:
    pkgs.runCommand "create-github-pr-skill" { } ''
      mkdir -p $out
      cp -r ${./create-github-pr} $out/create-github-pr
    '';
}
