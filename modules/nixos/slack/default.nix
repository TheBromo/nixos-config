{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.slack
    pkgs.slack-term
  ];
}
