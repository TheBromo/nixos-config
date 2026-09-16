# Formatting via treefmt-nix.
#
#   nix fmt                              format the whole repository
#   nix build .#checks.<system>.treefmt  verify formatting (used by CI)
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";

      programs.nixfmt.enable = true;
      programs.yamlfmt.enable = true;

      settings.global.excludes = [
        # git-crypt encrypted, must never be rewritten
        "secrets/**"
        "secret-key"
        "*.lock"
        "*.png"
        "*.jpg"
        "*.tar.xz"
        ".DS_Store"
      ];
    };
  };
}
