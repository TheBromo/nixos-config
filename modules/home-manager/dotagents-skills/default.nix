{ ... }:
{
  flake.lib.dotagentsSkills =
    pkgs:
    let
      src = pkgs.fetchgit {
        url = "https://forgejo.www.stefanjunker.de/steveej/dotagents.git";
        rev = "1a187d6f44a34c26f16e961647e4e2f683414bf8";
        hash = "sha256-NEBopMwhGspKTKttNLmM3OY3VC3O2rXATrcXtJDs2l0=";
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
