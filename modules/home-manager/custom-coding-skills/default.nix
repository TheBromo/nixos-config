{ ... }:
{
  flake.lib.customCodingSkills =
    pkgs:
    pkgs.runCommand "custom-coding-skills" { } ''
      mkdir -p $out
      cp -r ${./skills}/. $out/
    '';
}
