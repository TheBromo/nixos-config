{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.jetbrains.idea-ultimate
    pkgs.jetbrains.pycharm-professional
  ];
}
