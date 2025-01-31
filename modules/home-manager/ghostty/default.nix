{...}: {
  xdg.configFile."ghostty/config".text = ''
    theme = "Builtin Pastel Dark"

    font-family = TX-02
    font-size = 13

    shell-integration = zsh
    command = zsh

    keybind = ctrl+shift+h=goto_split:left
    keybind = ctrl+shift+l=goto_split:right
    keybind = ctrl+shift+j=goto_split:down
    keybind = ctrl+shift+k=goto_split:up

    #keybind = ctrl+shift+v=new_split:right
    keybind = ctrl+shift+s=new_split:down
  '';
}
