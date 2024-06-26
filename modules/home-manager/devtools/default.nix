{ pkgs, ... }: {
  home.packages = with pkgs; [
    jdk17
    rustc
    cargo
    rustfmt
    clippy
    gcc
    go-task
    nixpkgs-fmt
    nix-output-monitor

    jq
    zip
    unzip

    go
    gopls
    gotools
    gnumake
    cmake
    cunit
    jdk17
    glibc
    obsidian
  ];

}

