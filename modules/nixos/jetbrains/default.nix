{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
  ];
}
