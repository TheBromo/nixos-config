{ ... }:
{
  flake.lib.dotagentsSkills =
    pkgs:
    let
      src = pkgs.fetchgit {
        url = "https://forgejo.www.stefanjunker.de/steveej/dotagents.git";
        rev = "b6565cf1f294fc8aee08ffd5e4ce17d932b725c1";
        hash = "sha256-ykJ0vmrHhVFTMuZ47mfrFJJEwzEovZY7/BGbKPtKJOA=";
      };
      paths = {
        go = "skills/go";
        nix = "skills/nix";
      };
      cps = pkgs.lib.concatStringsSep "\n" (
        pkgs.lib.mapAttrsToList (name: p: "cp -r ${src}/${p} $out/${name}") paths
      );
    in
    pkgs.runCommand "dotagents-skills" { } ''
      mkdir -p $out
      ${cps}
    '';
}
