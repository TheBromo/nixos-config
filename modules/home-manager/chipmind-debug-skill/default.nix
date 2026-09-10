{ ... }:
{
  flake.lib.chipmindDebugSkill =
    pkgs:
    pkgs.runCommand "chipmind-debug-skill" { } ''
      mkdir -p $out
      cp -r ${./chipmind-debug} $out/chipmind-debug
    '';
}
