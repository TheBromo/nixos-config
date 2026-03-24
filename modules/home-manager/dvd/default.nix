{ self, inputs, ... }:
{
  flake.homeModules.dvd =
    { pkgs, ... }:
    {
      home.packages = [
        (import "${self}/pkgs/dvd" { inherit pkgs; })
      ];
    };
}
