{ ... }:
{
  flake.lib.reactDoctorSkill =
    pkgs:
    let
      src = pkgs.fetchFromGitHub {
        owner = "millionco";
        repo = "react-doctor";
        rev = "dfcde1035aca34e7bb8fbeea8da78cead7cc20e9";
        hash = "sha256-52ThO3KaURN8o4nDEJiHtSYHgoRMoBQa9w5IdFtzwSA=";
      };
    in
    pkgs.runCommand "react-doctor-skill" { } ''
      mkdir -p $out
      cp -r ${src}/skills/react-doctor $out/react-doctor
    '';
}
