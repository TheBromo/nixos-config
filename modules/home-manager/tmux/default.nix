{ pkgs, root, ... }:
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
      yank
      vim-tmux-navigator
    ];
    extraConfig = ''
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-option -sa terminal-overrides ",xterm*:Tc"

      set -g default-terminal "alacritty" 
      set-option -sa terminal-overrides ",alacritty*:Tc"

      set-environment -g COLORTERM "truecolor"

      set-option -g status-position top 
      set-option -g automatic-rename on

      bind C-s set-option -g status

      bind-key -r f run-shell "tmux neww tmux-sessionizer"

      # Set the left side of the status bar
      set -g status-left-length 30
      set -g status-left " ▲ #S | "
      set -g status-left-style fg="#303030",bg="#36c692"

      # Set the right side of the status bar
      set -g status-right " %H:%M %d-%b-%y "
      set -g status-right-style fg="#36c692",bg="#303030"

      set -g status-bg "#303030"
      set -g status-fg "#36c692"


      # Set the window status format
      set -g window-status-format " #I:[#W]#(basename #{pane_current_path}| cut -c1-5) "

      # Set the current window status format
      set -g window-status-current-format " #I:[#W]#(basename #{pane_current_path}| cut -c1-10) "
      set -g window-status-current-style fg="#303030",bg="#36c692"

    '';
  };

  programs.bash.bashrcExtra = ''
    bind -s '"\C-f":"tmux-sessionizer\n"'
  '';

  home.packages = [
    tmux-sessionizer
  ];
}
