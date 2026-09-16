# Build targets for CI: the same host closures, minus everything whose source is
# git-crypt encrypted. CI has no key, and the resulting closure is pushed to a
# public binary cache, so licensed content must stay out of it.
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
            modules = [ { custom.tx02.enable = false; } ];
          }).activationPackage
      ) (lib.filterAttrs (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system) self.homeConfigurations);
    };
}
