{ pkgs, home-manager, inputs, root, ... }: {

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    initialPassword = "changeme";
    shell = pkgs.bash;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.manuel = ({ ... }: {
      imports = [ ./../../home.nix ];
      home.stateVersion = "23.11";
    });
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}


