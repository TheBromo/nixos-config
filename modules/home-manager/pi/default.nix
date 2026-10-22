_: {
  flake.homeModules.pi =
    { inputs, pkgs, ... }:
    let
      # llm-agents.nix tracks pi releases several times a day. MIT and
      # redistributable, so unlike claude-code it needs no
      # custom.nonRedistributable gate.
      pi = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
    in
    {
      home.packages = [
        pi
        pkgs.python3
      ];
    };
}
