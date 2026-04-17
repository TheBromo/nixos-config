{ ... }:
{
  flake.homeModules.node =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.bun
        pkgs.nodejs_25
      ];

      programs.zsh.initContent = ''
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
      '';
    };
}
