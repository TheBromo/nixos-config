{ ... }:
{
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      fonts = {
        fontDir.enable = true;
        packages = [
          pkgs.noto-fonts
          pkgs.noto-fonts-color-emoji
          pkgs.nerd-fonts.jetbrains-mono
        ];
      };
    };
}
