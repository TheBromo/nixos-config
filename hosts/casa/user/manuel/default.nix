{ pkgs, inputs, root, ... }: {

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [ "vboxusers" "networkmanager" "wheel" "video" "docker" "wireshark" ];
    initialPassword = "changeme";
    shell = pkgs.bash;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.manuel = ({ ... }: {
      imports = [
        (root + "/modules/home-manager/git")
        (root + "/modules/home-manager/alacritty")
        (root + "/modules/home-manager/devtools")
        (root + "/modules/home-manager/console")
        (root + "/modules/home-manager/tmux")
      ];
      home = {
        stateVersion = "23.11";
      };
    });
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}


