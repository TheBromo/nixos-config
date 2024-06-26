{ pkgs, lib, root, ... }:
let
  tmux-sessionizer = import "${root}/pkgs/tmux-sessionizer" { inherit pkgs; };
in
{
  programs. tmux = {
    enable = true;
    baseIndex = 1;
    secureSocket = true;
    mouse = true;
    keyMode = "vi";
    clock24 = true;
    plugins = with pkgs.tmuxPlugins;[
      pain-control
      vim-tmux-navigator
      yank
    ];
    extraConfig = ''
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      bind C-s set-option -g status

      bind-key -r f run-shell "tmux neww tmux-sessionizer"

      # Set the left side of the status bar
      set -g status-left-length 20
      set -g status-left " ▲ #S | "
      set -g status-left-style fg=black,bg=green

      # Set the right side of the status bar
      set -g status-right " %H:%M %d-%b-%y "
      set -g status-right-style fg=green,bg=black

      set -g status-bg black
      set -g status-fg green

      # Set the window status format
      set -g window-status-format " #I: #W "

      # Set the current window status format
      set -g window-status-current-format " #I: #W "
      set -g window-status-current-style fg=black,bg=green

    '';

  };

  programs.bash.bashrcExtra = ''
    bind -s '"\C-f":"tmux-sessionizer\n"'
  '';

  home.packages = [
    tmux-sessionizer
  ];
}
