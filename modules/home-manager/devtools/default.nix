{ pkgs, ... }: {
  home.packages = with pkgs; [
    gcc
    go-task
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
  ];
}

