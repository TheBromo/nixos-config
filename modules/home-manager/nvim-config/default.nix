{ ... }:
{
  flake.homeModules.nvimConfig =
    {
      pkgs,
      lib,
      inputs,
      ...
    }:
    {
      home.packages = [
        inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default

        pkgs.ripgrep

        # nix
        pkgs.nixfmt
        pkgs.nixd

        # web
        pkgs.typescript-language-server
        pkgs.prettierd
        pkgs.tailwindcss-language-server

        # python
        pkgs.ty
        pkgs.ruff

        # kubernetes
        pkgs.kube-linter
        pkgs.yamlfmt
        # neovim
        pkgs.lua-language-server
        # cpp
        pkgs.llvmPackages_21.clang-tools

        pkgs.vscode-langservers-extracted
        pkgs.gopls
        pkgs.terraform-ls

        # treesitter
        pkgs.vimPlugins.nvim-treesitter-parsers.markdown
        pkgs.vimPlugins.nvim-treesitter-parsers.markdown_inline
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

      programs.zsh = {
        shellAliases = {
          vim = "nvim";
          vi = "nvim";
        };
        initContent = ''
          reopen_nvim() {
              fg
          }

          zle -N reopen_nvim
          bindkey '^Z' reopen_nvim
        '';
      };
    };
}
