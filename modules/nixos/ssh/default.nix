{...}: {
  services.openssh = {
    enable = true;

    extraConfig = ''
      AcceptEnv TMUX
    '';
  };
}
