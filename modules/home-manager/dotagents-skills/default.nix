{ ... }:
{
  flake.lib.dotagentsSkills =
    pkgs:
    let
      src = pkgs.fetchgit {
        url = "https://forgejo.www.stefanjunker.de/steveej/dotagents.git";
        rev = "04bc35f77bb8f1e473f98af1b50ac608d3660632";
        hash = "sha256-arhsmVWMRs42RpJ2nVccQTi6TbZjiRg/Kyl9s2K/C+Q=";
      };
      paths = {
        go = "skills/go";
        nix = "skills/nix";
        diagrams = "skills/diagrams";
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
