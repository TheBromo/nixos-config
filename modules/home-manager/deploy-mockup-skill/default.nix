{ ... }:
{
  flake.lib.deployMockupSkill =
    pkgs:
    pkgs.runCommand "deploy-mockup-skill" { } ''
      mkdir -p $out
      cp -r ${./deploy-mockup} $out/deploy-mockup
    '';
}
