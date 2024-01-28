{
  description = "My personal nixos config"; 
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl.url = github:nix-community/nixos-wsl;
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }@inputs: 
  {
    nixosConfigurations = {
	wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; 
	specialArgs = {inherit inputs;};
        modules = [ 
      	  ./hosts/wsl/configuration.nix
	  nixos-wsl.nixosModules.wsl
	  inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
