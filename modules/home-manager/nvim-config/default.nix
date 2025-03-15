{
  pkgs,
  lib,
  ...
}: {
  # home.packages = [
  #   pkgs.git
  #   pkgs.stdenv.cc
  #   pkgs.cargo
  #   pkgs.curl
  #   pkgs.fd
  #   pkgs.fzf
  #   pkgs.git
  #   pkgs.gnumake
  #   pkgs.gnused
  #   pkgs.gnutar
  #   pkgs.gzip
  #   pkgs.wget
  #   pkgs.ripgrep
  #   pkgs.tree-sitter
  #   pkgs.unzip
  #   pkgs.nodejs
  #   pkgs.python3
  #   pkgs.neovim-node-client
  #   pkgs.alejandra
  # ];
  #
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
