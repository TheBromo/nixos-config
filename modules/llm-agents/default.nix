# Packages from github:numtide/llm-agents.nix.
#
# Taken from the input's own `packages` output, not through
# `overlays.shared-nixpkgs`: those packages are built against upstream's own
# nixpkgs, which is what their CI pushes to https://cache.numtide.com, so they
# are downloaded instead of rebuilt. The overlay builds against our nixpkgs and,
# because we track nixos-unstable while upstream tracks nixpkgs-unstable, would
# miss that cache and compile codex from Rust source.
#
# The passthrough package exists so .github/workflows/ci.yml can realise the
# agent binary in a job that pushes nothing — see modules/home-manager/
# non-redistributable for why that distinction matters.
{ inputs, ... }:
{
  flake.lib.llmAgents = pkgs: inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  perSystem =
    { system, ... }:
    {
      packages = {
        inherit (inputs.llm-agents.packages.${system}) claude-code;
      };
    };
}
