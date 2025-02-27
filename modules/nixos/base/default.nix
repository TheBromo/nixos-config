{pkgs, ...}: {
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
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

    systemPackages = with pkgs; [
      unzip
      zip
      dnsutils
      coreutils
      btop
      git-crypt
      ghostty
    ];
  };
}
