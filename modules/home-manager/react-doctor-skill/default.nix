{ ... }:
{
  flake.lib.reactDoctorSkill =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "millionco";
        repo = "react-doctor";
        rev = "281fdc965635f0c7e3ad7d80d2c98bdf3d92ae52";
        hash = "sha256-jthOfSx4v3JXIpjrjfYx1FnNNa0sC7h4BU+VyE4xkgA=";
      };
    in
    pkgs.runCommand "react-doctor-skill" { } ''
      mkdir -p $out
      cp -r ${src}/skills/react-doctor $out/react-doctor
    '';
}
