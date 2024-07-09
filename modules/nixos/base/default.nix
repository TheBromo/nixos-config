{ pkgs, ... }:
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
      EDITOR = "${pkgs.neovim}/bin/nvim";
    };

    systemPackages = with pkgs; [
      unzip
      zip
      dnsutils
      coreutils
      btop
      git-crypt
      neovim
    ];
  };
}
