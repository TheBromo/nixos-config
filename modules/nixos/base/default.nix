{ pkgs, neovim-config, pkgs, ... }:
let
  neovim = neovim-config.makeDistribution pkgs;
in
{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  environment = {
    variables = {
	EDITOR = "${neovim}/bin/nvim";
    };

    systemPackages = with pkgs; [
      coreutils
      neovim
      htop
    ];
  };
}
