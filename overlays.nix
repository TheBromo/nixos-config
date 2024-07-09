{ neovim-config, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      neovim = neovim-config.packages.${final.system}.default;
    })
  ];
}
