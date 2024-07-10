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

    gnumake
    cmake
    glibc

    obsidian
  ];

}

