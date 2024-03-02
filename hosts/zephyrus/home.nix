{ config, pkgs, inputs, root, ... }:
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "manuel";
  home.homeDirectory = "/home/manuel";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    alacritty
    firefox

    rustc
    cargo
    rustfmt
    clippy
    git
    gcc
    go-task
    nixpkgs-fmt

    go
    gopls
    gotools

    eza
    fzf
    starship
    bash
    nerdfonts
  ];

  programs.git-credential-oauth.enable = true;

  programs.git = {
    enable = true;
    userName = "thebromo";
    userEmail = "manuel@strenge.ch";
  }; # Home Manager is pretty good at managing dotfiles. The primary way to manage

  # plain files is through 'home.file
  programs.eza = {
    enable = true;
    enableAliases = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
    git = true;
    icons = true;
  };

  programs.fzf = {
    enable = true;
  };
  #  programs.light.enable = true;

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "full";
      };
      font = {
        size = 12.0;
        normal.family = "GeistMono Nerd Font";
        bold.family = "GeistMono Nerd Font";
        italic.family = "GeistMono Nerd Font";
      };
    };
  };

  programs.fzf.enableBashIntegration = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };
  home.file = {
    #".config/nvim".source = "${neovimConfigRepo}/";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/nixos/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
