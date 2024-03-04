{ pkgs, home-manager, inputs, root, ... }: {

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    initialPassword = "changeme";
    packages = with pkgs; [
        firefox
        jetbrains.idea-ultimate
        nerdfonts
    ];
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
          (root + "/modules/home-manager/sway")
          (root + "/modules/home-manager/console")
         # (root + "/modules/home-manager/
      ];
      home.pointerCursor = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
        size = 24;
        x11 = {
          enable = true;
          defaultCursor = "Adwaita";
        };
      };
      home.stateVersion = "23.11";
    });
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}


