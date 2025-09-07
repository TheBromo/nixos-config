{
  pkgs,
  home-manager,
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  programs.zsh.enable = true;
  users.users.manuel = {
    isNormalUser = true;
    description = "manuel";
    extraGroups = [
      "wheel"
      "docker"
    ];
    initialPassword = "changeme";
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.manuel =
      { ... }:
      {
        imports = [
          "${self}/modules/home-manager/git"
          "${self}/modules/home-manager/devtools"
          "${self}/modules/home-manager/console"
          "${self}/modules/home-manager/tmux"
        ];
        home.stateVersion = "23.11";
      };
    extraSpecialArgs = {
      inherit inputs self;
    };
  };
}
