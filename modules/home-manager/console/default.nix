{ pkgs, root, ... }:
let
  bs = import "${root}/pkgs/branch-switcher" { inherit pkgs; };
  info = import "${root}/pkgs/info" { inherit pkgs; };
  dvt = import "${root}/pkgs/dvt" { inherit pkgs; };
  dvd = import "${root}/pkgs/dvd" { inherit pkgs; };
in
{
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "-x"
      "--color=never"
      "--classify=always"
    ];
    git = true;
  };

  home.packages = [
    pkgs.bat
    bs
    info
    dvt
    dvd
    pkgs.spotify-player
  ];

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cd = "z";
      cat = "bat";
      bs = "branch-switcher";
      lg = "lazygit";
      vim = "nvim";
      vi = "nvim";
      k = "kubectl";
    };
    bashrcExtra = ''
      source <(kubectl completion bash) 
      complete -F __start_kubectl k

      export PATH=$PATH:$HOME/go/bin
    '';

    initExtra = ''
      screenfetch
    '';
  };

  programs.direnv.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  home.file.".config/starship.toml".source = ./starship-pure.toml;

}
