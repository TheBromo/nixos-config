{ pkgs, home-manager, inputs, root, ... }: {

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  programs.zsh.enable = true;
  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [ "wheel" "docker" ];
    initialPassword = "changeme";
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.manuel = ({ ... }: {
      imports = [
        "${root}/modules/home-manager/git"
        "${root}/modules/home-manager/devtools"
        "${root}/modules/home-manager/console"
        "${root}/modules/home-manager/tmux"
      ];
      home.stateVersion = "23.11";
    });
    extraSpecialArgs = {
      inherit inputs root;
    };
  };
}


