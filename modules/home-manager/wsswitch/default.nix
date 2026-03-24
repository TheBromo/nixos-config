{ self, inputs, ... }:
{
  flake.homeModules.wsswitch =
    { pkgs, ... }:
    {
      home.packages = [
        (import "${self}/pkgs/wsswitch" { inherit pkgs; })
      ];
    };
}
