{ self, inputs, ... }:
{
  flake.homeModules.dvt =
    { pkgs, ... }:
    {
      home.packages = [
        (import "${self}/pkgs/dvt" { inherit pkgs; })
      ];
    };
}
