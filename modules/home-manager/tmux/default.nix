{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    secureSocket = true;
    mouse = true;
    keyMode = "vi";
    clock24 = true;
    shortcut = "a";
    escapeTime = 10;
    shell = "${pkgs.zsh}/bin/zsh";

    plugins = with pkgs.tmuxPlugins; [
      pain-control
      yank
      vim-tmux-navigator
    ];

    extraConfig = ''
      set -g default-terminal "$TERM"
      set -ag terminal-overrides ",$TERM:Tc"

      #set-option -g status-position top
      set-option -g automatic-rename on

      bind C-s set-option -g status
      bind-key -r f run-shell "tmux neww tms"

      # left side
      set -g status-left-length 30
      set -g status-left " ∫ #I  "
      set -g status-left-style fg="#A9DC76,bold",bg="#19181A"

      # right side
      set -g status-right " %H:%M %d-%b-%y "
      set -g status-right-style fg="#A9DC76",bg="#19181A"


      set -g status-bg "#19181A"
      set -g status-fg "#A9DC76"


      # Set the window status format
      set -g window-status-format " #I:#( \
        if [ \"#{pane_current_command}\" = \"zsh\" ]; then \
          basename \"#{pane_current_path}\" | cut -c1-10; \
        else \
          echo \"#{pane_current_command}\"; \
        fi \
      ) "

      # Set the current window status format
      set -g window-status-current-format " #I:#(basename #{pane_current_path}| cut -c1-10) "
      set -g window-status-current-style fg="#19181A",bg="#A9DC76"
    '';
  };

  programs.bash.bashrcExtra = ''
    bind -s '"\C-t":"tms\n"'
  '';

  programs.zsh.initContent = ''
    bindkey -s "^T" "tms\n"
  '';

  home.packages = [
    pkgs.tmux-sessionizer
  ];

  home.file.".config/tms/config.toml".text = ''
    [[search_dirs]]
    path = "/home/manuel/Development"
    depth = 1

    [[search_dirs]]
    path = "/home/manuel/.config"
    depth = 1
  '';
}
