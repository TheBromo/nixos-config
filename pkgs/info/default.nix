{pkgs, ...}:
pkgs.writeScriptBin "screenfetch" (builtins.readFile ./nix.sh)
