{ pkgs, home-manager, inputs, root, ... }: {

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
    shell = pkgs.zsh;    
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


