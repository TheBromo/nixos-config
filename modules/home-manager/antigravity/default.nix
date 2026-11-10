{ self, ... }:
{
  # Google Antigravity CLI (`agy`), the successor to gemini-cli, whose Gemini
  # Code Assist sign-in no longer works for individuals.
  flake.homeModules.antigravity =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      # Unfree and not redistributable, so it stays out of the CI closure that
      # is pushed to the public cache; see modules/home-manager/non-redistributable.
      home.packages = lib.optionals config.custom.nonRedistributable.enable [
        (self.lib.llmAgents pkgs).antigravity-cli
        # ACP server (`agy_acp_server`) that T3 Code's Antigravity provider
        # talks to; a separate install from the CLI.
        pkgs.antigravity-acp
      ];
    };
}
