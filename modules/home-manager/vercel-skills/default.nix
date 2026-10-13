{ ... }:
{
  flake.lib.vercelSkills =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "vercel-labs";
        repo = "agent-skills";
        rev = "063bee94c3f4df8453406c830b0a7df0f2860278";
        hash = "sha256-tTSJf53OQltUfxTH4hdqcnw5ywCjCZP8/JqQ593cyB8=";
      };
    in
    pkgs.runCommand "vercel-skills" { } ''
      mkdir -p $out
      cp -r ${src}/skills/composition-patterns $out/composition-patterns
      cp -r ${src}/skills/react-best-practices $out/react-best-practices
      cp -r ${src}/skills/react-view-transitions $out/react-view-transitions
      cp -r ${src}/skills/web-design-guidelines $out/web-design-guidelines
      cp -r ${src}/skills/writing-guidelines $out/writing-guidelines
    '';
}
