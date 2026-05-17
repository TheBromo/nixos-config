{ ... }:
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      environment.systemPackages = [
        pkgs.curl
        pkgs.wget
      ];
    };
}
