# One switch for everything whose licence forbids republication.
#
# .github/workflows/build.yml pushes the ci-<host> closure to the *public*
# thebromo cache, and cachix pushes every store path the job produced —
# substituted ones included, measured on run 35069655787. So such a path must
# never enter that job's store at all, not merely stay out of the final closure.
# modules/ci therefore sets this to false.
#
# The assertion turns a forgotten home.packages entry into an evaluation error
# instead of a licence violation on a public cache. It keys on
# meta.license.redistributable, which llm-agents.nix sets correctly: it patches
# license.free = true but leaves redistributable = false.
{ ... }:
{
  flake.homeModules.nonRedistributable =
    { config, lib, ... }:
    let
      licensesOf =
        package:
        let
          license = package.meta.license or [ ];
        in
        if builtins.isList license then license else [ license ];

      # A meta.license can be a plain string, and "str".redistributable or true
      # throws instead of defaulting, hence the isAttrs guard.
      isForbidden =
        package:
        builtins.any (license: builtins.isAttrs license && !(license.redistributable or true)) (
          licensesOf package
        );

      forbidden = builtins.filter isForbidden config.home.packages;
    in
    {
      options.custom.nonRedistributable.enable =
        lib.mkEnableOption "packages whose licence forbids republication"
        // {
          default = true;
        };

      # `||` short-circuits, so the filter costs nothing on a real host.
      config.assertions = [
        {
          assertion = config.custom.nonRedistributable.enable || forbidden == [ ];
          message =
            "custom.nonRedistributable.enable is false, but home.packages still contains: "
            + lib.concatMapStringsSep ", " (package: package.name or "<unnamed>") forbidden;
        }
      ];
    };
}
