{ pkgs, inputs, root, ... }: {

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [ "vboxusers" "networkmanager" "wheel" "video" "wireshark" ];
    initialPassword = "changeme";
    packages = with pkgs; [
      google-chrome
    ];
    shell = pkgs.bash;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.manuel = ({ ... }: {
      imports = [
        "${root}/modules/home-manager/git"
        "${root}/modules/home-manager/alacritty"
        "${root}/modules/home-manager/devtools"
        "${root}/modules/home-manager/console"
        "${root}/modules/home-manager/tmux"
      ];

      gtk.enable = true;
      home = {
        stateVersion = "23.11";
        pointerCursor = {
          name = "macOS-BigSur";
          package = pkgs.apple-cursor;
          gtk.enable = true;
          x11 = {
            enable = true;
            defaultCursor = "macOS-BigSur";
          };
          size = 24;
        };
        file.".icons/default".source = "${pkgs.apple-cursor}/share/icons/macOS-BigSur";
        sessionVariables = {
          XCURSOR_SIZE = 24;
        };
      };
    });
    extraSpecialArgs = {
      inherit inputs root;
    };
  };
}

