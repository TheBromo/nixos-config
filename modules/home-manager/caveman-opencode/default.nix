# Caveman's native opencode payload, laid out the way upstream's
# `bin/install.js --only opencode` would write it under ~/.config/opencode.
{ ... }:
{
  flake.lib.cavemanOpencode =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "JuliusBrussee";
        repo = "caveman";
        rev = "2fd153c67988e980fb0b2455c90832159a6a5a25";
        hash = "sha256-KFfU8LmNajKLZcOXOFisn4beTcg2YL+rpasr39UgSZE=";
      };
      skills = [
        "caveman"
        "caveman-commit"
        "caveman-review"
        "caveman-help"
        "caveman-stats"
        "caveman-compress"
        "cavecrew"
      ];
    in
    pkgs.runCommand "caveman-opencode" { } ''
      mkdir -p $out/plugins/caveman $out/commands $out/agents $out/skills

      # The plugin directory is ESM, so the CommonJS helpers need .cjs.
      cp ${src}/src/plugins/opencode/plugin.js ${src}/src/plugins/opencode/package.json $out/plugins/caveman/
      cp ${src}/src/hooks/caveman-config.js $out/plugins/caveman/caveman-config.cjs
      cp ${src}/src/hooks/caveman-parse.js $out/plugins/caveman/caveman-parse.cjs

      cp ${src}/src/plugins/opencode/commands/*.md $out/commands/

      # opencode rejects Claude's `tools: [...]` array and provider-less model
      # names such as `model: haiku`, so drop both from the frontmatter.
      for agent in ${src}/agents/cavecrew-*.md; do
        ${pkgs.gawk}/bin/awk '
          /^---$/ { fence++; skipping = 0; print; next }
          fence == 1 && /^tools[ \t]*:/ { skipping = 1; next }
          fence == 1 && skipping && /^[ \t]/ { next }
          fence == 1 && /^model[ \t]*:/ && !/\// { skipping = 0; next }
          { skipping = 0; print }
        ' "$agent" > $out/agents/$(basename "$agent")
      done

      for skill in ${pkgs.lib.escapeShellArgs skills}; do
        cp -r ${src}/skills/$skill $out/skills/$skill
      done

      {
        echo '<!-- caveman-begin -->'
        cat ${src}/src/rules/caveman-activate.md
        echo '<!-- caveman-end -->'
      } > $out/AGENTS.md
    '';
}
