{ ... }: {

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    shortcut = "a";
    terminal = "screen-256color";
    clock24 = true;
  };

}
