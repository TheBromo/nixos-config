{ ... }:
{
  flake.homeModules.terraform =
    { pkgs, ... }:
    {

      home = {
        packages = [
          pkgs.terraform
          pkgs.azure-cli
          pkgs.opentofu
          pkgs.just
          pkgs.age
        ];
        sessionVariables = {
          PARAGON_EMPLOYEE_VAULT_OP = "EMPLOYEE";
          PARAGON_GITLAB_ADMIN_PAT_ITEM_OP = "Gitlab admin PAT";
          PARAGON_GITLAB_ADMIN_PAT_OP = "op://Employee/Gitlab admin PAT/credential";
        };
      };
    };
}
