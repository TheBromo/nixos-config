{
  pkgs,
  ...
}:
{
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
  ];
  home.packages = with pkgs; [
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
    dotnet-sdk_6
    flyctl

    ninja
    gettext
    terraform
    azure-cli
    opentofu
    kubernetes-helm
  ];
}
