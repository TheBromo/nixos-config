{ pkgs, root, ... }:
let
  bs = import "${root}/pkgs/branch-switcher" { inherit pkgs; };
  info = import "${root}/pkgs/info" { inherit pkgs; };
  dvt = import "${root}/pkgs/dvt" { inherit pkgs; };
  dvd = import "${root}/pkgs/dvd" { inherit pkgs; };
in
{
  home.packages = [
    pkgs.bat
    pkgs.zsh
    pkgs.zoxide
    pkgs._1password-cli
    pkgs.fzf
    pkgs.direnv
    pkgs.starship
    bs
    info
    dvt
    dvd
    pkgs.spotify-player
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh= {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      cd = "z";
      cat = "bat";
      bs = "branch-switcher";
      lg = "lazygit";
      vim = "nvim";
      vi = "nvim";
      k = "kubectl";

    };

    initExtra = ''
        source <(kubectl completion zsh)
        export GOPATH=$HOME/go
        screenfetch
    '';
  };

  programs.direnv={
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".config/starship.toml".source = ./starship-pure.toml;

}
