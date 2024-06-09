{ pkgs, root, ... }:
let
  bs = import "${root}/pkgs/branch-switcher" { inherit pkgs; };
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
    #icons = true;
  };

  home.packages = with pkgs; [
    bat
    bs
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
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
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
