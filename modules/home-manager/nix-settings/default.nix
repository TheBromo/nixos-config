# Consume the binary cache that .github/workflows/build.yml fills, so a switch
# downloads the closure instead of compiling tree-sitter, ghostty and friends.
#
# Written to ~/.config/nix/nix.conf. A non-NixOS daemon install only honours it
# when the user is listed in trusted-users; otherwise Nix ignores the extra
# substituter with a warning.
{ ... }:
{
  flake.homeModules.nixSettings =
    { pkgs, ... }:
    {
      # Only used to validate the generated nix.conf; it is not added to
      # home.packages, so the daemon's own client stays in charge.
      nix.package = pkgs.nix;

      nix.settings = {
        extra-substituters = [
          "https://thebromo.cachix.org"
          "https://nix-community.cachix.org"
          "https://ghostty.cachix.org"
          # Prebuilt agent binaries from the llm-agents.nix input. Only useful
          # because that input has no `nixpkgs.follows`.
          "https://cache.numtide.com"
        ];
        extra-trusted-public-keys = [
          "thebromo.cachix.org-1:Brqme/xyjfgPo1plbGcsdKKPTTJy4i8xnkZ4AvN2Xps="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };
    };
}
