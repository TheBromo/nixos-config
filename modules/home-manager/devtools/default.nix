{ pkgs,root, ... }: 
let
  uvision-flash = import "${root}/pkgs/uvision-flash" { inherit pkgs; };
  uvision-gdb   = import "${root}/pkgs/uvision-gdb" { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    gcc
    nixpkgs-fmt
    nix-output-monitor

    jq
    zip
    unzip
    openssl

    go
    gopls
    gotools

    
    k9s
    kubectl
    kubectx
    kubectl-neat
    kubectl-example
    kind
    minikube
    

    gnumake
    cmake
    glibc

    obsidian

    #for keil arm
    gdbgui
    vscode-fhs

    #stlink

    #uvision-flash
    #uvision-gdb

    imhex
  ];
}

