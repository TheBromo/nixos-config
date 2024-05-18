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
      jetbrains.idea-ultimate
      nerdfonts
      wireshark
    ];
    shell = pkgs.bash;
  };



  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

  environment = {
    sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
    sessionVariables.NIXOS_OZONE_WL = "1";

  };

  programs.wireshark.enable = true;


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
        pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          name = "MacOS";
          package = pkgs.apple-cursor;
          size = 16;
        };
        sessionVariables = {
          GTK_CURSOR_THEME = "MacOS";
        };
      };
    });
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}


