{ ... }:
{
  flake.homeModules.terraform =
    { pkgs, ... }:
    {

      home.packages = [
        pkgs.terraform
        pkgs.azure-cli
        pkgs.opentofu
        pkgs.just
      ];

      programs.zsh.initContent = ''
        export PARAGON_GITLAB_ADMIN_PAT_OP="op://Employee/Gitlab admin PAT/credential"
        export PARAGON_EMPLOYEE_VAULT_OP="EMPLOYEE"
        export PARAGON_GITLAB_ADMIN_PAT_ITEM_OP="Gitlab admin PAT"
      '';
    };
}
