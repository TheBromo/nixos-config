{
  pkgs,
  lib,
  ...
}:
{
  home.packages = [
    #nix
    pkgs.nixfmt-rfc-style
    pkgs.nil
    #web
    pkgs.typescript-language-server
    pkgs.prettierd
    pkgs.tailwindcss-language-server
    #python
    pkgs.ty
    pkgs.ruff
    #kubernetes
    pkgs.kube-linter
    pkgs.yamlfmt
    pkgs.yaml-language-server
    #neovim
    pkgs.lua-language-server
    #cpp
    pkgs.llvmPackages_21.clang-tools
  ];

  home.activation = {
    configureNvim = lib.mkAfter ''
      mkdir -p ~/.config/nvim
      if [ -z "$(ls -A ~/.config/nvim)" ] || [ ! -d ~/.config/nvim/.git ]; then
        ${pkgs.git}/bin/git clone https://github.com/TheBromo/neovim-config.git ~/.config/nvim
      else
        echo "Neovim configuration already exists. Skipping clone."
      fi
      chmod -R u+w ~/.config/nvim
    '';
  };
}
