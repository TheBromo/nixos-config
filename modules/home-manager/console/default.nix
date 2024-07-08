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
    ];
    git = true;
  };

  home.packages = [
    pkgs.bat
    bs
    info
    dvt
    dvd
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
    };
    initExtra = ''
      screenfetch
    '';
  };

  programs.direnv.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      directory = {
        style = "bold #36c692";
      };
      battery = {
        full_symbol = "• ";
        charging_symbol = "⇡ ";
        discharging_symbol = "⇣ ";
        unknown_symbol = "❓ ";
        empty_symbol = "❗ ";
      };

      erlang = {
        symbol = "ⓔ ";
      };

      nodejs = {
        symbol = "[⬢](bold green) ";
      };

      pulumi = {
        symbol = "🧊 ";
      };

      typst = {
        symbol = "t ";
      };
    };
  };

}
