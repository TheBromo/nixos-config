# Build targets for CI: the same host closures, minus everything whose licence
# forbids republication — the git-crypt encrypted font and the prebuilt
# claude-code binary. The closure is pushed to a public binary cache, and CI has
# no git-crypt key anyway.
#
#   nix build .#packages.<system>.ci-<host>
{ self, lib, ... }:
{
  perSystem =
    { system, ... }:
    {
      packages = lib.mapAttrs' (
        name: homeConfiguration:
        lib.nameValuePair "ci-${name}"
          (homeConfiguration.extendModules {
            modules = [ { custom.nonRedistributable.enable = false; } ];
          }).activationPackage
      ) (lib.filterAttrs (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system) self.homeConfigurations);
    };
}
