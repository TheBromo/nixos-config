{...}: {
  xdg.configFile."ghostty/config".text = ''
    theme = "Builtin Pastel Dark"

    font-family = TX-02
    font-size = 13
    font-feature = -calt, -liga, -dlig

    shell-integration = zsh
    command = zsh

    keybind = alt+h=goto_split:left
    keybind = alt+l=goto_split:right
    keybind = alt+j=goto_split:down
    keybind = alt+k=goto_split:up
    keybind = ctrl+shift+l=next_tab
    keybind = ctrl+shift+h=previous_tab

    keybind = alt+v=new_split:right
    keybind = alt+s=new_split:down



  '';
}
