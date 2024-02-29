{ config, pkgs, ... }:
let
  neovimConfigRepo = builtins.fetchGit {
    url = "https://github.com/TheBromo/nvim-config.git";
    rev = "c50d380b69ab0d8282e996785148098c6a1c72d0";
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "manuel";
  home.homeDirectory = "/home/manuel";

  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    git
    gcc
    go-task
    nixpkgs-fmt
    firefox

    rustc
    cargo
    rustfmt
    clippy
    go
    gopls
    gotools
    eza
    fzf
    starship
    bash
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (nerdfonts.override { fonts = [ "GeistMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
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

  programs.fzf.enableBashIntegration = true;

  programs.bash = {
    enable = true;
    bashrcExtra = "";
    enableCompletion = true;
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };


  home.file = {
    #".config/nvim".source = "${neovimConfigRepo}/";
    #".screenrc".source = dotfiles/screenrc;
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
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
