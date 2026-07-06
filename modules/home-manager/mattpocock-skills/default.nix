{ ... }:
{
  flake.lib.mattpocockSkills =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "mattpocock";
        repo = "skills";
        rev = "6eeb81b5fcfeeb5bd531dd47ab2f9f2bbea27461";
        hash = "sha256-6T0KwZcUIIbd6kpkQXPCnnJPVY2mEjxYjed4FjKnRAw=";
      };
      paths = {
        codebase-design = "engineering/codebase-design";
        diagnosing-bugs = "engineering/diagnosing-bugs";
        domain-modeling = "engineering/domain-modeling";
        grill-me = "productivity/grill-me";
        grill-with-docs = "engineering/grill-with-docs";
        grilling = "productivity/grilling";
        improve-codebase-architecture = "engineering/improve-codebase-architecture";
        prototype = "engineering/prototype";
        teach = "productivity/teach";
        to-issues = "engineering/to-issues";
        to-prd = "engineering/to-prd";
        triage = "engineering/triage";
        writing-great-skills = "productivity/writing-great-skills";
        decision-mapping = "in-progress/decision-mapping";
        git-guardrails-claude-code = "misc/git-guardrails-claude-code";
        obsidian-vault = "personal/obsidian-vault";
        request-refactor-plan = "deprecated/request-refactor-plan";
        resolving-merge-conflicts = "engineering/resolving-merge-conflicts";
        review = "in-progress/review";
      };
      cps = pkgs.lib.concatStringsSep "\n" (
        pkgs.lib.mapAttrsToList (name: p: "cp -r ${src}/skills/${p} $out/${name}") paths
      );
    in
    pkgs.runCommand "mattpocock-skills" { } ''
      mkdir -p $out
      ${cps}
    '';
}
