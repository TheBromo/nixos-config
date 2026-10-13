# Caveman's "small rock": the skills that `npx skills add JuliusBrussee/caveman -g`
# would install, plus a rule file so every session starts in caveman mode
# without typing /caveman. Every agent harness consumes these two outputs:
#   - cavemanSkills: the skill directories, copied into each harness's skills dir
#   - cavemanRules:  the always-on rule, used as each harness's global
#                    CLAUDE.md / AGENTS.md
{ ... }:
let
  src =
    pkgs:
    pkgs.fetchFromGitHub {
      owner = "JuliusBrussee";
      repo = "caveman";
      rev = "2e08b9177c07bb7249a8a2d1a6758e5db281d002";
      hash = "sha256-przOot/S0VLw2aP3tOdxF27mZHMp0NQhyTls0eDAjjs=";
    };

  # cavecrew is left out: it only delegates to the cavecrew-* subagents,
  # which belong to the plugins and are not installed.
  skills = [
    "caveman"
    "caveman-commit"
    "caveman-review"
    "caveman-help"
    "caveman-stats"
    "caveman-compress"
  ];
in
{
  flake.lib.cavemanSkills =
    pkgs:
    pkgs.runCommand "caveman-skills" { } ''
      mkdir -p $out
      for skill in ${pkgs.lib.escapeShellArgs skills}; do
        cp -r ${src pkgs}/skills/$skill $out/$skill
      done
    '';

}
