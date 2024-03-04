{ pkgs, ... }: {

  programs.git-credential-oauth.enable = true;

  programs.git = {
    enable = true;
    userName = "thebromo";
    userEmail = "manuel@strenge.ch";
  };
}
