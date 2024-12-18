{ pkgs,ghostty, ... }:
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
                  ghostty.packages.x86_64-linux.default


    ];
  };
}
