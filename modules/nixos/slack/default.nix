{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    slack
    slack-term
  ];
}
