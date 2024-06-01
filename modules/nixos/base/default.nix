{ pkgs, neovim-config, ... }:
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

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
      permittedInsecurePackages = [
        "nix-2.16.2"
      ];

    };

  };

  environment = {
    variables = {
      EDITOR = "${neovim}/bin/nvim";
    };

    systemPackages = with pkgs; [
      unzip
      zip
      coreutils
      dnsutils
      coreutils
      htop
      git-crypt
      neovim
    ];
  };
}
