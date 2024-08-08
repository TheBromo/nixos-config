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
      set -g default-terminal "$TERM"
      set -ag terminal-overrides ",$TERM:Tc"

      set-option -g status-position top 
      set-option -g automatic-rename on

      bind C-s set-option -g status
      bind-key -r f run-shell "tmux neww tmux-sessionizer"

      # left side 
      set -g status-left-length 30
      set -g status-left " ▲ #S "
      set -g status-left-style fg="green,bold",bg="black"

      # right side 
      set -g status-right " %H:%M %d-%b-%y "
      set -g status-right-style fg="green",bg="black"


      set -g status-bg "black"
      set -g status-fg "green"


      # Set the window status format
      set -g window-status-format " #I:#( \
        if [ \"#{pane_current_command}\" = \"bash\" ]; then \
          basename \"#{pane_current_path}\" | cut -c1-10; \
        else \
          echo \"#{pane_current_command}\"; \
        fi \
      ) "

      # Set the current window status format
      set -g window-status-current-format " #I:#(basename #{pane_current_path}| cut -c1-10) "
      set -g window-status-current-style fg="black",bg="green"
    '';
  };

  programs.bash.bashrcExtra = ''
    bind -s '"\C-f":"tmux-sessionizer\n"'
  '';

  home.packages = [
    tmux-sessionizer
  ];
}
