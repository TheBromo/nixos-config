{
  pkgs,
  root,
  ...
}: {
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
  ];
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
    dotnet-sdk_6
    protobuf
    jdt-language-server
    java-language-server
    maven
    zulu
  ];
}
