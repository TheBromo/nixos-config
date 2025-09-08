{
  pkgs,
  self,
  ...
}:
let
  info = import "${self}/pkgs/info" { inherit pkgs; };
  dvt = import "${self}/pkgs/dvt" { inherit pkgs; };
  dvd = import "${self}/pkgs/dvd" { inherit pkgs; };
  wsswitch = import "${self}/pkgs/wsswitch" { inherit pkgs; };
in
{
  home.packages = [
    info
    dvt
    dvd
    wsswitch
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
    autosuggestion.enable = false;
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

    initContent = ''
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

      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"

      source "$HOME/.sdkman/bin/sdkman-init.sh"
      source $HOME/.local/bin/env
      source <(kubectl completion zsh)
      export GOPATH=$HOME/go
      export PATH=$PATH:$HOME/go/bin
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
    '';
  };
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    daemon.enable = true;
    flags = [
      "--disable-up-arrow"
    ];
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
    settings = {
      format = "$character $directory";
      right_format = "$cmd_duration$shlvl[$username@$hostname](cyan)";
      add_newline = false;

      character = {
        format = "$symbol";
        success_symbol = "[▲](bold green)";
        error_symbol = "[△](bold red)";
        vimcmd_symbol = "[▲](bold purple)";
      };

      username = {
        format = "$user";
        show_always = true;
      };
      directory = {
        style = "bold green";
      };

      hostname = {
        format = "$hostname";
        ssh_only = false;
      };

      shlvl = {
        disabled = false;
        format = "[$symbol]($style) ";
        symbol = "";
        threshold = 3;
      };

      cmd_duration = {
        format = "[$duration](bold yellow) ";
      };
    };
  };
}
