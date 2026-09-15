{ ... }:
{
  flake.homeModules.node =
    { pkgs, ... }:
    let
      nvmInit = ''
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
      '';
    in
    {
      home = {
        packages = [
          pkgs.bun
          pkgs.nodejs_26
        ];
        sessionPath = [ "$HOME/.bun/bin" ];
        sessionVariables = {
          BUN_INSTALL = "$HOME/.bun";
          NVM_DIR = "$HOME/.nvm";
        };
      };

      programs.npm = {
        enable = true;
        package = null;
        settings.prefix = "\${HOME}/.local";
      };

      programs.bash.initExtra = nvmInit;
      programs.zsh.initContent = nvmInit;
    };
}
