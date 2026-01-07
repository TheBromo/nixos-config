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
  # programs.zsh.enable = true;

  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [
      "vboxusers"
      "networkmanager"
      "wheel"
      "video"
      "wireshark"
    ];
    initialPassword = "changeme";
    packages = [
      pkgs.google-chrome
    ];
    # shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.manuel =
      { ... }:
      {
        dconf = {
          enable = true;
          settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
        };

        imports = [
          "${self}/modules/home-manager/git"
          "${self}/modules/home-manager/alacritty"
          "${self}/modules/home-manager/devtools"
          "${self}/modules/home-manager/edutools"
          "${self}/modules/home-manager/console"
          "${self}/modules/home-manager/nvim-config"
          "${self}/modules/home-manager/tmux"
        ];

        gtk.enable = true;
        home = {
          stateVersion = "23.11";
        };
      };
    extraSpecialArgs = {
      inherit inputs self;
    };
  };
}
