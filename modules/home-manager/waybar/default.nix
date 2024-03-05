{ pkgs, ... }: {

  home.packages = with pkgs; [
    waybar
    pavucontrol
  ];

  programs.waybar = {
    enable = true;
    settings = import ./waybar/config.nix;
    style = ''
      ${builtins.readFile ./waybar/style.css} 
    '';
  };
}
