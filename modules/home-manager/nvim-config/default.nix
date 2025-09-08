{
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    neovim
    #nix
    nixfmt-rfc-style
    nixd
    #web
    typescript-language-server
    prettierd
    tailwindcss-language-server
    #python
    ty
    ruff
    #kubernetes
    kube-linter
    yamlfmt
    yaml-language-server
    #neovim
    lua-language-server
    #cpp
    llvmPackages_21.clang-tools

    vscode-langservers-extracted
    gopls
    terraform-ls
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
