{ self, inputs, ... }:
{
  flake.nixosModules.manuelUser =
    { pkgs, ... }:
    {
      users.users.manuel = {
        isNormalUser = true;
        description = "Manuel";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        packages = [
          pkgs.google-chrome
        ];
      };

      home-manager = {
        useUserPackages = true;
        extraSpecialArgs = {
          inherit self inputs;
        };
        users.manuel = self.homeModules.manuelConfiguration;
      };
    };
}
