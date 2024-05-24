{ pkgs, ... }: {
  environment.systempackages = with pkgs; [
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional

  ];
}
