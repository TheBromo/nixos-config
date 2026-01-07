{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.tree
    pkgs.gcc
    pkgs.nix-output-monitor
    pkgs.nixfmt-rfc-style

    pkgs.jq
    pkgs.zip
    pkgs.unzip
    pkgs.openssl

    pkgs.rustup
    pkgs.go
    pkgs.zig
    pkgs.gopls
    pkgs.gotools

    pkgs.k9s
    pkgs.kubectl
    pkgs.kubectx
    pkgs.kubectl-neat
    pkgs.kubectl-example
    pkgs.kind
    pkgs.minikube

    pkgs.gnumake
    pkgs.cmake
    pkgs.cilium-cli
    #pkgs.glibc

    pkgs.undollar
    pkgs.gdbgui
    pkgs.flyctl
    pkgs.azure-cli
    pkgs.uv

    pkgs.ninja
    pkgs.gettext
    pkgs.terraform
    pkgs.azure-cli
    pkgs.opentofu
    pkgs.kubernetes-helm
  ];
}
