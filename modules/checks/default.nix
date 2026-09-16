# Re-exports every home configuration as a flake check, so that
# `nix flake check` covers them. `homeConfigurations` is not a standard flake
# output and would otherwise be ignored.
#
# Only the configurations whose target system matches the evaluated system are
# exported, because a check has to be buildable on that system.
{ self, lib, ... }:
{
  perSystem =
    { system, ... }:
    {
      checks = lib.mapAttrs' (
        name: homeConfiguration: lib.nameValuePair "home-${name}" homeConfiguration.activationPackage
      ) (lib.filterAttrs (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system) self.homeConfigurations);
    };
}
