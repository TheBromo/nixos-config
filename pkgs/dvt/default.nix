{ pkgs, ... }:let 
    githash = "d5ad3c909c004f202019f662bf7304ee59f6b5e4";
in pkgs.writeScriptBin "dvt" ''
  #!${pkgs.bash}/bin/bash
  if [ -z $1 ]; then
    echo "no template specified"
    exit 1
  fi

  TEMPLATE=$1

  nix \
    --experimental-features 'nix-command flakes' \
    flake init \
    --template \
    "github:the-nix-way/dev-templates/${githash}#''${TEMPLATE}"

  direnv allow
''

