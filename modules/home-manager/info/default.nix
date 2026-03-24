{ self, inputs, ... }:
{
  flake.homeModules.info =
    { pkgs, ... }:
    {
      home.packages = [
        (import "${self}/pkgs/info" { inherit pkgs; })
      ];
    };
}
