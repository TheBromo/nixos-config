{ ... }:
{
  flake.homeModules.terraform =
    { pkgs, ... }:
    let
      setuptofu = pkgs.writeShellScriptBin "setuptofu" ''
        set -euo pipefail

        echo "==> Authenticating to Azure..."
        az login

        echo "==> Setting up GitLab token for OpenTofu backend..."
        export GITLAB_TOKEN="$(op read "$PARAGON_GITLAB_ADMIN_PAT_OP")"

        echo "==> Setting up 1Password account..."
        export OP_ACCOUNT=$(op account get | awk '/^ID:/ {print $2}')

        echo "==> Generating state.config from 1Password..."
        op inject --in-file state.config.in --out-file state.config

        echo "==> Running tofu init..."
        op run -- tofu init -backend-config state.config "$@"

        echo "==> Generating secrets.tfvars from 1Password..."
        op inject --in-file secrets.tfvars.in --out-file secrets.tfvars

        echo "==> Done! You can now run: tofu plan -var-file=secrets.tfvars"
      '';
    in
    {

      home.packages = [
        pkgs.terraform
        pkgs.azure-cli
        pkgs.opentofu
        setuptofu
      ];

      programs.zsh.initContent = ''
        export PARAGON_GITLAB_ADMIN_PAT_OP="op://Employee/Gitlab admin PAT/credential"
        export PARAGON_EMPLOYEE_VAULT_OP="EMPLOYEE"
        export PARAGON_GITLAB_ADMIN_PAT_ITEM_OP="Gitlab admin PAT"
      '';
    };
}
