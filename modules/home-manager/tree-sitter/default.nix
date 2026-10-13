{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      tree-sitter-src = pkgs.fetchFromGitHub {
        owner = "tree-sitter";
        repo = "tree-sitter";
        tag = "v0.27.1";
        hash = "sha256-KbPqA6pfplWRUtwRgbNXUF7aivj/n4shJqWbjNO93nQ=";
        fetchSubmodules = true;
      };
    in
    {
      packages.tree-sitter-cli = pkgs.tree-sitter.overrideAttrs (old: {
        version = "0.27.1";
        src = tree-sitter-src;
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          src = tree-sitter-src;
          hash = "sha256-GbW/qFq8X0UNi9LIepTIAKSAqCXM/gdy6XV6s5YO8r0=";
        };
        patches = [ ];
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.rustPlatform.bindgenHook ];
      });
    };
}
