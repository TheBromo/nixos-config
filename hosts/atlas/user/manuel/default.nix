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
  programs.zsh.enable = true;

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
          "${self}/modules/home-manager/ghostty"
          "${self}/modules/home-manager/devtools"
          "${self}/modules/home-manager/edutools"
          "${self}/modules/home-manager/console"
          "${self}/modules/home-manager/nvim-config"
          "${self}/modules/home-manager/tmux"
          "${self}/modules/home-manager/timewarrior-auto"
        ];

        gtk.enable = true;
        home = {
          stateVersion = "25.05";
        };
      };
    extraSpecialArgs = {
      inherit inputs self;
    };
  };
}
