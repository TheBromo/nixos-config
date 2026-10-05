{ self, ... }:
{
  flake.homeModules.opencode =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      llmAgents = self.lib.llmAgents pkgs;
      configDir = "${config.xdg.configHome}/opencode";
    in
    {
      programs.opencode = {
        enable = true;
        # MIT and redistributable, so unlike claude-code no nonRedistributable
        # gate is needed.
        package = llmAgents.opencode;
        settings = {
          # Authenticate against Amazon Bedrock with the ambient AWS
          # credentials (AWS_PROFILE from the console module), like claude.
          model = "amazon-bedrock/us.anthropic.claude-opus-5-5";
          provider.amazon-bedrock.options.region = "us-east-1";

          permission = "allow";
          autoupdate = false;

          mcp = {
            chrome-devtools = {
              type = "local";
              command = [
                (lib.getExe' pkgs.nodejs_26 "npx")
                "-y"
                "chrome-devtools-mcp@latest"
                "--isolated"
              ];
            };
            swiss_caselaw = {
              type = "remote";
              url = "https://mcp.opencaselaw.ch/sse";
            };
          };
        };
      };

      # Not programs.opencode.context: it only accepts strings and literal
      # paths, not a derivation. force: the caveman plugin installer left a
      # plain AGENTS.md here.
      xdg.configFile."opencode/AGENTS.md" = {
        source = self.lib.cavemanRules pkgs;
        force = true;
      };

      # Never set programs.opencode.skills to a path: home-manager would link
      # ~/.config/opencode/skills, and check-link-targets would then refuse to
      # clobber the copies made below.
      home.activation.installOpencodeSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Remove what the former caveman plugin install copied in. opencode
        # loads everything under plugins/, so a stale copy would stay active.
        rm -rf "${configDir}/plugins/caveman" "${configDir}/skills/cavecrew"
        rm -f "${configDir}"/agents/cavecrew-{builder,investigator,reviewer}.md
        rm -f "${configDir}"/commands/caveman{,-commit,-compress,-help,-review,-stats}.md

        mkdir -p "${configDir}/skills"
        cp -rf --no-preserve=mode ${self.lib.mattpocockSkills pkgs}/. "${configDir}/skills/"
        cp -rf --no-preserve=mode ${self.lib.dotagentsSkills pkgs}/. "${configDir}/skills/"
        cp -rf --no-preserve=mode ${self.lib.ghStackSkill pkgs}/. "${configDir}/skills/"
        cp -rf --no-preserve=mode ${self.lib.conventionalGitSkills pkgs}/. "${configDir}/skills/"
        cp -rf --no-preserve=mode ${self.lib.createGithubPrSkill pkgs}/. "${configDir}/skills/"
        cp -rf --no-preserve=mode ${self.lib.chipmindDebugSkill pkgs}/. "${configDir}/skills/"
        cp -rf --no-preserve=mode ${self.lib.reactDoctorSkill pkgs}/. "${configDir}/skills/"
        cp -rf --no-preserve=mode ${self.lib.frontendDesignSkill pkgs}/. "${configDir}/skills/"
        cp -rf --no-preserve=mode ${self.lib.securityAuditSkill pkgs}/. "${configDir}/skills/"
        cp -rf --no-preserve=mode ${self.lib.cavemanSkills pkgs}/. "${configDir}/skills/"
      '';
    };
}
