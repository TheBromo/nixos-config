{ pkgs, home-manager, inputs, root, ... }: {

  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [ "networkmanager" "wheel" "video" "wireshark" ];
    initialPassword = "changeme";
    packages = with pkgs; [
      firefox
      unzip
      zip
      coreutils
      dnsutils
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
      nerdfonts
      wireshark
    ];
    shell = pkgs.bash;
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
        (root + "/modules/home-manager/sway")
        (root + "/modules/home-manager/wofi")
        (root + "/modules/home-manager/waybar")
        (root + "/modules/home-manager/console")
      ];
      home.pointerCursor = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
        size = 12;
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


