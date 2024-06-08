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
