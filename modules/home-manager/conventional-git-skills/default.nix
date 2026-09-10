{ ... }:
{
  flake.lib.conventionalGitSkills =
    pkgs:
    let
      commitsSrc = pkgs.fetchFromGitHub {
        owner = "dgalarza";
        repo = "claude-code-workflows";
        rev = "df2f11ef8d990df22e7b528ca7f5c634943317b8";
        hash = "sha256-hbip8Eg9tbkfCYTiAM40oUqd+LxLJx6MOQMN3D/zikM=";
      };
      branchSrc = pkgs.fetchFromGitHub {
        owner = "github";
        repo = "awesome-copilot";
        rev = "f95f1b4c3b153984e3da2744cef395c2355d0a44";
        hash = "sha256-E476CEZ6YkYbB2Hfe+jALg6nyBvQRTRuqzsUj5wIQrU=";
      };
    in
    pkgs.runCommand "conventional-git-skills" { } ''
      mkdir -p $out
      cp -r ${commitsSrc}/plugins/conventional-commits/skills/conventional-commits $out/conventional-commits
      cp -r ${branchSrc}/skills/conventional-branch $out/conventional-branch
    '';
}
