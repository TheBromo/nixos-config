{ self, inputs, ... }:
{
  flake.nixosModules.manuelUser =
    { ... }:
    {
      users.users.manuel = {
        isNormalUser = true;
        description = "Manuel";
        extraGroups = [
          "networkmanager"
          "wheel"
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
