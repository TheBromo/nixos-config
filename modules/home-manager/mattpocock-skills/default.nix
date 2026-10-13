{ ... }:
{
  flake.lib.mattpocockSkills =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "mattpocock";
        repo = "skills";
        rev = "b0618bc436ad893b3c5e84e55fba86586d34a404";
        hash = "sha256-1QwFBwG+gORvDvW4HM0LrZlHZKmKtWr7pUHU0MAXF2Y=";
      };
      paths = {
        ask-matt = "engineering/ask-matt";
        code-review = "engineering/code-review";
        codebase-design = "engineering/codebase-design";
        diagnosing-bugs = "engineering/diagnosing-bugs";
        domain-modeling = "engineering/domain-modeling";
        grill-me = "productivity/grill-me";
        grill-with-docs = "engineering/grill-with-docs";
        grilling = "productivity/grilling";
        handoff = "productivity/handoff";
        implement = "engineering/implement";
        implement-spec = "engineering/implement-spec";
        improve-codebase-architecture = "engineering/improve-codebase-architecture";
        pr = "engineering/pr";
        prototype = "engineering/prototype";
        research = "engineering/research";
        retro = "engineering/retro";
        setup-matt-pocock-skills = "engineering/setup-matt-pocock-skills";
        tdd = "engineering/tdd";
        teach = "productivity/teach";
        to-questionnaire = "productivity/to-questionnaire";
        to-tickets = "engineering/to-tickets";
        to-spec = "engineering/to-spec";
        triage = "engineering/triage";
        wait-what = "productivity/wait-what";
        wizard = "engineering/wizard";
        writing-for-agents = "productivity/writing-for-agents";
        wayfinder = "engineering/wayfinder";
        git-guardrails-claude-code = "misc/git-guardrails-claude-code";
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
