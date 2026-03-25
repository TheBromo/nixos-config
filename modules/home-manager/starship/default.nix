{ ... }:
{
  flake.homeModules.starship =
    { ... }:
    {

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          format = "$character $directory";
          right_format = "$cmd_duration$shlvl[$username@$hostname](cyan)";
          add_newline = false;

          character = {
            format = "$symbol";
            success_symbol = "[▲](bold green)";
            error_symbol = "[△](bold red)";
            vimcmd_symbol = "[▲](bold purple)";
          };

          username = {
            format = "$user";
            show_always = true;
          };

          directory = {
            style = "bold green";
          };

          hostname = {
            format = "$hostname";
            ssh_only = false;
          };

          shlvl = {
            disabled = false;
            format = "[$symbol]($style) ";
            symbol = "";
            threshold = 3;
          };

          cmd_duration = {
            format = "[$duration](bold yellow) ";
          };
        };
      };
    };
}
