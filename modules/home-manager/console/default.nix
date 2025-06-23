{
  pkgs,
  root,
  ...
}: let
  info = import "${root}/pkgs/info" {inherit pkgs;};
  dvt = import "${root}/pkgs/dvt" {inherit pkgs;};
  dvd = import "${root}/pkgs/dvd" {inherit pkgs;};
  wsswitch = import "${root}/pkgs/wsswitch" {inherit pkgs;};
in {
  home.packages = [
    info
    dvt
    dvd
    wsswitch
    pkgs.spotify-player
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    shellAliases = {
      cd = "z";
      cat = "bat";
      lg = "lazygit";
      vim = "nvim";
      vi = "nvim";
      k = "kubectl";
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
    };

    initExtra = ''
      function cd_from_ws() {
        local target=$(wsswitch)
        if [[ -d "$target" ]]; then
          cd "$target"
        else
          print -ru2 "Error: '$target' is not a valid directory."
        fi

        zle reset-prompt
      }

      reopen_nvim() {
          fg
      }


      zle -N cd_from_ws
      zle -N reopen_nvim 

      bindkey '^F' cd_from_ws
      bindkey '^Z' reopen_nvim

      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

      export PATH="$HOME/neovim/bin:$PATH"
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"


      source "$HOME/.sdkman/bin/sdkman-init.sh"
      source $HOME/.local/bin/env
      source <(kubectl completion zsh)
      export GOPATH=$HOME/go
      export PATH=$PATH:$HOME/go/bin
      export PATH="$HOME/neovim/bin:$PATH"
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.bat = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".config/starship.toml".source = ./starship.toml;
}
