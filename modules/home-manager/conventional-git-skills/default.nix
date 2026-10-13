{ ... }:
{
  flake.lib.conventionalGitSkills =
    pkgs:
    let
      commitsSrc = pkgs.fetchFromGitHub {
        owner = "dgalarza";
        repo = "claude-code-workflows";
        rev = "464c7171f1a67aebf1527ae0f150829b66d8f784";
        hash = "sha256-titaxsGJ/qdzM+wF4YNus7tcCiOYCX7yVljA0MWxsJA=";
      };
      branchSrc = pkgs.fetchFromGitHub {
        owner = "github";
        repo = "awesome-copilot";
        rev = "82701c24b99488536ca399ff4789a458b7a05db7";
        hash = "sha256-JTjeYPsfQ+ICTSpok/1RjdNyy7D+D7IRUKd8HPmPJBw=";
      };
    in
    pkgs.runCommand "conventional-git-skills" { } ''
      mkdir -p $out
      cp -r ${commitsSrc}/plugins/conventional-commits/skills/conventional-commits $out/conventional-commits
      cp -r ${branchSrc}/skills/conventional-branch $out/conventional-branch
    '';
}
