{ ... }:
{
  flake.homeModules.slack =
    {
      config,
      pkgs,
      ...
    }:
    let
      slack = config.lib.nixGL.wrap pkgs.slack;
    in
    {
      home.packages = [ slack ];

      xdg.desktopEntries.slack = {
        name = "Slack";
        genericName = "Team Communication";
        exec = "${slack}/bin/slack -s %U";
        icon = "slack";
        terminal = false;
        type = "Application";
        categories = [
          "Network"
          "InstantMessaging"
          "Chat"
        ];
        mimeType = [
          "x-scheme-handler/slack"
        ];
        settings.StartupWMClass = "Slack";
      };
    };
}
