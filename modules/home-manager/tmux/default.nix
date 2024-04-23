{ pkgs, ... }:
{

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    secureSocket = false;
    shortcut = "a";
    mouse = true;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins;[
      pain-control
      vim-tmux-navigator
      sensible
      yank
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
        '';

      }
    ];
    extraConfig = ''
      set -g default-terminal "xterm-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      # bind '"' split-window -c "#{pane_current_path}"
      # bind '%' split-window -h -c "#{pane_current_path}"
      set-option -g status-position top
    '';
  };
}
