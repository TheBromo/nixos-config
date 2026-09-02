{ ... }:
{
  flake.homeModules.nvimConfig =
    {
      pkgs,
      lib,
      self,
      inputs,
      ...
    }:
    {
      home.packages = [
        inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default
        self.packages.${pkgs.stdenv.hostPlatform.system}.tree-sitter-cli

        pkgs.ripgrep

        # nix
        pkgs.nixfmt
        pkgs.nil

        # web
        pkgs.typescript-language-server
        pkgs.prettierd
        pkgs.tailwindcss-language-server
        pkgs.vscode-langservers-extracted

        # python
        pkgs.ty
        pkgs.ruff

        # rust
        pkgs.rust-analyzer

        # shell
        pkgs.bash-language-server

        # containers
        pkgs.docker-language-server

        # kubernetes
        pkgs.kube-linter
        pkgs.yamlfmt
        pkgs.yaml-language-server

        # documentation and configuration
        pkgs.marksman
        pkgs.taplo

        # neovim
        pkgs.lua-language-server

        # cpp
        pkgs.llvmPackages_21.clang-tools

        # system verilog
        pkgs.verible
        pkgs.svls

        pkgs.gopls

        pkgs.terraform-ls
      ];

      home.activation = {
        configureNvim = lib.mkAfter ''
          mkdir -p ~/.config/nvim
          if [ -z "$(ls -A ~/.config/nvim)" ]; then
            ${pkgs.git}/bin/git clone https://github.com/TheBromo/neovim-config.git ~/.config/nvim
          else
            echo "Neovim configuration already exists. Skipping clone."
          fi
          chmod -R u+w ~/.config/nvim
        '';
      };

      home.shellAliases = {
        vi = "nvim";
        vim = "nvim";
      };
    };
}
