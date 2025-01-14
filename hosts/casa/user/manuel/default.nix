{ pkgs, inputs, root, ... }: {

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  programs.zsh.enable = true;

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [ "vboxusers" "networkmanager" "wheel" "video" "docker" "wireshark" ];
    initialPassword = "changeme";
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.manuel = ({ ... }: {
      dconf = {
          enable = true;
          settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };
      imports = [
        "${root}/modules/home-manager/git"
        "${root}/modules/home-manager/alacritty"
        "${root}/modules/home-manager/devtools"
        "${root}/modules/home-manager/console"
        "${root}/modules/home-manager/tmux"
        "${root}/modules/home-manager/nvim-config"
      ];
      home = {
        stateVersion = "23.11";
      };
    });
    extraSpecialArgs = {
      inherit inputs root;
    };
  };
}


