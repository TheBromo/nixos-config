_: {
  flake.homeModules.wsswitch =
    { lib, pkgs, ... }:
    let
      renderShellScript =
        path: substitutions:
        builtins.replaceStrings (builtins.attrNames substitutions) (builtins.attrValues substitutions) (
          builtins.readFile path
        );
      # `rex` comes from the Rex app; wsswitch.sh calls its bundled CLI.
      wsswitch = pkgs.writeShellApplication {
        name = "wsswitch";
        text = renderShellScript ./wsswitch.sh {
          "@find@" = lib.getExe' pkgs.findutils "find";
          "@fzf@" = lib.getExe pkgs.fzf;
          "@jq@" = lib.getExe pkgs.jq;
          "@realpath@" = lib.getExe' pkgs.coreutils "realpath";
        };
      };
    in
    {
      home.packages = [ wsswitch ];

      programs.zsh.initContent = lib.mkAfter ''
        function rex_ws_switch() {
          zle -I
          ${lib.getExe wsswitch}
          zle reset-prompt
        }

        zle -N rex_ws_switch
        bindkey '^F' rex_ws_switch
      '';

      programs.bash.initExtra = lib.mkAfter ''
        function rex_ws_switch() {
          ${lib.getExe wsswitch}
        }

        bind -x '"\C-f":rex_ws_switch'
      '';
    };
}
