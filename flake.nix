{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rolling: an update bot merges roughly four times a day, so flake.lock is
    # the only pin. Deliberately no `inputs.nixpkgs.follows`: we track
    # nixos-unstable, upstream tracks nixpkgs-unstable, and a mismatch means
    # missing https://cache.numtide.com and compiling codex from Rust source.
    llm-agents.url = "github:numtide/llm-agents.nix";

    nixgl.url = "github:nix-community/nixGL";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      imports = [
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
      ];
    };
}
