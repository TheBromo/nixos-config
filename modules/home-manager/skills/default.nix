# Every agent skill in one place. `agentSkills pkgs` is a single directory of
# skill folders that each agent harness (claude, codex, opencode) copies into
# its skills dir.
#   - local/:  skills written in this repo (edit them there)
#   - remotes: skills pinned from upstream repos, as { name = path-in-src; }
{ ... }:
let
  remotes = pkgs: {
    mattpocock = {
      src = pkgs.fetchFromGitHub {
        owner = "mattpocock";
        repo = "skills";
        rev = "b0618bc436ad893b3c5e84e55fba86586d34a404";
        hash = "sha256-1QwFBwG+gORvDvW4HM0LrZlHZKmKtWr7pUHU0MAXF2Y=";
      };
      skills = {
        ask-matt = "skills/engineering/ask-matt";
        code-review = "skills/engineering/code-review";
        codebase-design = "skills/engineering/codebase-design";
        diagnosing-bugs = "skills/engineering/diagnosing-bugs";
        domain-modeling = "skills/engineering/domain-modeling";
        grill-me = "skills/productivity/grill-me";
        grill-with-docs = "skills/engineering/grill-with-docs";
        grilling = "skills/productivity/grilling";
        handoff = "skills/productivity/handoff";
        implement = "skills/engineering/implement";
        implement-spec = "skills/engineering/implement-spec";
        improve-codebase-architecture = "skills/engineering/improve-codebase-architecture";
        pr = "skills/engineering/pr";
        prototype = "skills/engineering/prototype";
        research = "skills/engineering/research";
        retro = "skills/engineering/retro";
        setup-matt-pocock-skills = "skills/engineering/setup-matt-pocock-skills";
        tdd = "skills/engineering/tdd";
        teach = "skills/productivity/teach";
        to-questionnaire = "skills/productivity/to-questionnaire";
        to-tickets = "skills/engineering/to-tickets";
        to-spec = "skills/engineering/to-spec";
        triage = "skills/engineering/triage";
        wait-what = "skills/productivity/wait-what";
        wizard = "skills/engineering/wizard";
        writing-for-agents = "skills/productivity/writing-for-agents";
        wayfinder = "skills/engineering/wayfinder";
        git-guardrails-claude-code = "skills/misc/git-guardrails-claude-code";
      };
    };

    dotagents = {
      src = pkgs.fetchgit {
        url = "https://forgejo.www.stefanjunker.de/steveej/dotagents.git";
        rev = "04bc35f77bb8f1e473f98af1b50ac608d3660632";
        hash = "sha256-arhsmVWMRs42RpJ2nVccQTi6TbZjiRg/Kyl9s2K/C+Q=";
      };
      skills = {
        go = "skills/go";
        nix = "skills/nix";
        diagrams = "skills/diagrams";
      };
    };

    gh-stack = {
      src = pkgs.fetchFromGitHub {
        owner = "github";
        repo = "gh-stack";
        rev = "fc2b03d34528917574b41d4d749a477263a6afc5";
        hash = "sha256-/TpZwsIvLczKzqCU+Ez/TGeGsXegUHSoQdXo/nLhC/o=";
      };
      skills.gh-stack = "skills/gh-stack";
    };

    conventional-commits = {
      src = pkgs.fetchFromGitHub {
        owner = "dgalarza";
        repo = "claude-code-workflows";
        rev = "464c7171f1a67aebf1527ae0f150829b66d8f784";
        hash = "sha256-titaxsGJ/qdzM+wF4YNus7tcCiOYCX7yVljA0MWxsJA=";
      };
      skills.conventional-commits = "plugins/conventional-commits/skills/conventional-commits";
    };

    awesome-copilot = {
      src = pkgs.fetchFromGitHub {
        owner = "github";
        repo = "awesome-copilot";
        rev = "82701c24b99488536ca399ff4789a458b7a05db7";
        hash = "sha256-JTjeYPsfQ+ICTSpok/1RjdNyy7D+D7IRUKd8HPmPJBw=";
      };
      skills.conventional-branch = "skills/conventional-branch";
    };

    react-doctor = {
      src = pkgs.fetchFromGitHub {
        owner = "millionco";
        repo = "react-doctor";
        rev = "281fdc965635f0c7e3ad7d80d2c98bdf3d92ae52";
        hash = "sha256-jthOfSx4v3JXIpjrjfYx1FnNNa0sC7h4BU+VyE4xkgA=";
      };
      skills.react-doctor = "skills/react-doctor";
    };

    claude-code = {
      src = pkgs.fetchFromGitHub {
        owner = "anthropics";
        repo = "claude-code";
        rev = "e47cc82bdbd27b5f799acd5b05fd0c29d33bb48c";
        hash = "sha256-sjF2i7gu2cDCz1jCLpvQeoV2VCNqpkKETZutQeW1DPo=";
      };
      skills.frontend-design = "plugins/frontend-design/skills/frontend-design";
    };

    vercel = {
      src = pkgs.fetchFromGitHub {
        owner = "vercel-labs";
        repo = "agent-skills";
        rev = "063bee94c3f4df8453406c830b0a7df0f2860278";
        hash = "sha256-tTSJf53OQltUfxTH4hdqcnw5ywCjCZP8/JqQ593cyB8=";
      };
      skills = {
        composition-patterns = "skills/composition-patterns";
        react-best-practices = "skills/react-best-practices";
        react-view-transitions = "skills/react-view-transitions";
        web-design-guidelines = "skills/web-design-guidelines";
        writing-guidelines = "skills/writing-guidelines";
      };
    };

    cloudflare-security-audit = {
      src = pkgs.fetchFromGitHub {
        owner = "cloudflare";
        repo = "security-audit-skill";
        rev = "c1c8a8c1471069fb0e188eeaff69b8e8db6564a8";
        hash = "sha256-oVVACjotkHvllQGxEP8yWaEt4c3GxT0d909TUM5P3NM=";
      };
      skills.security-audit = "skills/security-audit";
      # The skill dir has no license of its own; ship the repo's with it.
      license = "LICENSE";
    };

    # Caveman's "small rock": the skills that
    # `npx skills add JuliusBrussee/caveman -g` would install. cavecrew is left
    # out: it only delegates to the cavecrew-* subagents, which belong to the
    # plugins and are not installed.
    caveman = {
      src = pkgs.fetchFromGitHub {
        owner = "JuliusBrussee";
        repo = "caveman";
        rev = "2e08b9177c07bb7249a8a2d1a6758e5db281d002";
        hash = "sha256-przOot/S0VLw2aP3tOdxF27mZHMp0NQhyTls0eDAjjs=";
      };
      skills = pkgs.lib.genAttrs [
        "caveman"
        "caveman-commit"
        "caveman-review"
        "caveman-help"
        "caveman-stats"
        "caveman-compress"
      ] (name: "skills/${name}");
    };
  };
in
{
  flake.lib.agentSkills =
    pkgs:
    let
      inherit (pkgs) lib;

      copyRemote =
        _: remote:
        lib.mapAttrsToList (name: path: ''
          cp -r --no-preserve=mode ${remote.src}/${path} $out/${name}
          ${lib.optionalString (remote ? license) "cp ${remote.src}/${remote.license} $out/${name}/LICENSE"}
        '') remote.skills;

      names =
        builtins.attrNames (builtins.readDir ./local)
        ++ lib.concatMap (r: builtins.attrNames r.skills) (builtins.attrValues (remotes pkgs));
      duplicates = lib.unique (lib.filter (n: lib.count (m: m == n) names > 1) names);
    in
    assert lib.assertMsg (
      duplicates == [ ]
    ) "agentSkills: skill names defined twice: ${toString duplicates}";
    pkgs.runCommand "agent-skills" { } ''
      mkdir -p $out
      cp -r --no-preserve=mode ${./local}/. $out/
      ${lib.concatStrings (lib.flatten (lib.mapAttrsToList copyRemote (remotes pkgs)))}
    '';
}
