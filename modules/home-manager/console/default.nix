{
  pkgs,
  root,
  ...
}: let
  info = import "${root}/pkgs/info" {inherit pkgs;};
  dvt = import "${root}/pkgs/dvt" {inherit pkgs;};
  dvd = import "${root}/pkgs/dvd" {inherit pkgs;};
in {
  home.packages = [
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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      cd = "z";
      cat = "bat";
      lg = "lazygit";
      vim = "nvim";
      vi = "nvim";
      k = "kubectl";
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
    };

    initExtra = ''
      source <(kubectl completion zsh)
      export GOPATH=$HOME/go
      screenfetch
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.bat = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  home.file.".config/starship.toml".source = ./starship-pure.toml;
}
