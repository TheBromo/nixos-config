{ pkgs, ... }:
pkgs.writeScriptBin "dvt" ''
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
  "github:the-nix-way/dev-templates#''${TEMPLATE}"

  direnv allow
''

