# Static analysis of the Nix sources.
#
#   nix build .#checks.<system>.lint
#
# statix reads the repository's statix.toml, which disables the two lints that
# conflict with the module style used here (see that file for the reasoning).
{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      src = lib.fileset.toSource {
        root = ../../.;
        fileset = lib.fileset.unions [
          (lib.fileset.fileFilter (file: file.hasExt "nix") ../../.)
          ../../statix.toml
          ../../.github/workflows
        ];
      };
    in
    {
      checks.lint =
        pkgs.runCommand "lint"
          {
            nativeBuildInputs = [
              pkgs.statix
              pkgs.deadnix
              pkgs.actionlint
              # actionlint uses shellcheck for the `run:` blocks when it is
              # available
              pkgs.shellcheck
            ];
          }
          ''
            cd ${src}
            statix check .
            deadnix --fail .
            # explicit paths, because actionlint otherwise looks for a Git root
            actionlint .github/workflows/*.yml
            touch $out
          '';
    };
}
