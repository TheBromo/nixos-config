{ ... }:
{
  flake.lib.securityAuditSkill =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "cloudflare";
        repo = "security-audit-skill";
        rev = "c1c8a8c1471069fb0e188eeaff69b8e8db6564a8";
        hash = "sha256-oVVACjotkHvllQGxEP8yWaEt4c3GxT0d909TUM5P3NM=";
      };
    in
    pkgs.runCommand "security-audit-skill" { } ''
      mkdir -p $out
      cp -r --no-preserve=mode ${src}/skills/security-audit $out/security-audit
      cp ${src}/LICENSE $out/security-audit/LICENSE
    '';
}
