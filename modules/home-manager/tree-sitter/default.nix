{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      tree-sitter-src = pkgs.fetchFromGitHub {
        owner = "tree-sitter";
        repo = "tree-sitter";
        tag = "v0.26.7";
        hash = "sha256-O3c2djKhM+vIYunthDApi9sw/gFH/FBME1uR4N+9MFM=";
        fetchSubmodules = true;
      };
    in
    {
      packages.tree-sitter-cli = pkgs.tree-sitter.overrideAttrs (old: {
        version = "0.26.7";
        src = tree-sitter-src;
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          src = tree-sitter-src;
          hash = "sha256-zh6KsnZ7s6VXGCggoYbLGeGnEZ7g7anjkz8C5/L4yXQ=";
        };
        patches = [ ];
        nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.rustPlatform.bindgenHook ];
      });
    };
}
