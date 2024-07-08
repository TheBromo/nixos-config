{ pkgs, ... }:
pkgs.writeScriptBin "dvt" ''
  #!${pkgs.bash}/bin/bash
  nix flake init -t "github:the-nix-way/dev-templates/d5ad3c909c004f202019f662bf7304ee59f6b5e4?dir=$1"

  direnv allow
''

