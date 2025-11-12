{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    tree
    gcc
    nix-output-monitor
    nixfmt-rfc-style

    jq
    zip
    unzip
    openssl

    rustup
    go
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

    gnumake
    cmake
    #glibc

    undollar
    gdbgui
    flyctl
    azure-cli
    uv

    ninja
    gettext
    terraform
    azure-cli
    opentofu
    kubernetes-helm
  ];
}
