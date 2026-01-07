{ pkgs, ... }:
{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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
      allowUnfreePredicate = _: true;
    };
  };

  environment = {
    variables = {
      EDITOR = "nvim";
    };

    systemPackages = [
      pkgs.unzip
      pkgs.zip
      pkgs.dnsutils
      pkgs.coreutils
      pkgs.btop
      pkgs.git-crypt
      # pkgs.ghostty
    ];
  };
}
