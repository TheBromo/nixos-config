{
  pkgs,
  root,
  ...
}: {
  home.packages = with pkgs; [
    gcc
    nixpkgs-fmt
    nix-output-monitor

    jq
    zip
    unzip
    openssl

    go
    cargo
    zig
    gopls
    gotools

    k9s
    kubectl
    kubectx
    kubectl-neat
    kubectl-example
    kind
    minikube
    node2nix
    nodejs
    pnpm
    yarn

    gnumake
    cmake
    glibc

    undollar
    gdbgui
  ];
}
