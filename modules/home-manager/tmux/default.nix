{ pkgs, lib, ... }:
let
  tmux-sessionizer = pkgs.writeScriptBin "tmux-sessionizer" ''
        #!${pkgs.bash}/bin/bash

        if [[ $# -eq 1 ]]; then
        selected=$1
    else
        selected=$(find ~/Development -mindepth 1 -maxdepth 1 -type d | fzf)
    fi

    if [[ -z $selected ]]; then
        exit 0
    fi

    selected_name=$(basename "$selected" | tr . _)
    tmux_running=$(pgrep tmux)

    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        tmux new-session -s $selected_name -c $selected
        exit 0
    fi

    if ! tmux has-session -t=$selected_name 2> /dev/null; then
        tmux new-session -ds $selected_name -c $selected
    fi

    if [[ -z $TMUX ]]; then
        tmux attach -t $selected_name
    else
        tmux switch-client -t $selected_name
    fi

  '';
in
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    secureSocket = true;
    mouse = true;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins;[
      pain-control
      vim-tmux-navigator
      sensible
      yank
    ];
    extraConfig = ''
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      set -g status-style 'bg=#181616 fg=#c5c9c5'
      set -g mode-keys vi

      bind-key -r f run-shell "tmux neww tmux-sessionizer"
    '';

  };

  programs.bash.bashrcExtra = ''
    bind -s '"\C-f":"tmux-sessionizer\n"'
  '';

  home.packages = [
    tmux-sessionizer
  ];
}
