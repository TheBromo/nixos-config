{
  pkgs,
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [
      "vboxusers"
      "networkmanager"
      "wheel"
      "video"
      "docker"
      "wireshark"
    ];
    initialPassword = "changeme";
    shell = pkgs.bash;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.manuel =
      { ... }:
      {
        imports = [
          "${self}/modules/home-manager/git"
          "${self}/modules/home-manager/alacritty"
          "${self}/modules/home-manager/devtools"
          "${self}/modules/home-manager/console"
          "${self}/modules/home-manager/tmux"
        ];
        home = {
          stateVersion = "23.11";
        };
      };
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}
