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
    go
    gopls
    gotools

  ];

}

