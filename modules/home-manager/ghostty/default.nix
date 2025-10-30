{ config, pkgs, ... }:
{
  programs.ghostty = {
    package = (config.lib.nixGL.wrap pkgs.ghostty);
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "Builtin Pastel Dark";

      font-family = [
        "TX-02"
        "Apple Color Emoji"
      ];
      font-size = 13;
      font-feature = "-calt, -liga, -dlig";

      shell-integration = "zsh";
      command = "zsh";

      macos-icon = "xray";

      keybind = [
        "alt+h=goto_split:left"
        "ctrl+shift+l=goto_split:right"
        "ctrl+shift+j=goto_split:down"
        "ctrl+shift+k=goto_split:up"
        "ctrl+shift+]=next_tab"
        "ctrl+shift+[=previous_tab"
        "alt+v=new_split:right"
        "alt+s=new_split:down"
      ];
    };
  };

}
