{ ... }:
{
  flake.homeModules.appleCursor =
    { pkgs, ... }:
    let
      cursorTheme = "macOS";
      cursorSize = 24;
    in
    {
      home.pointerCursor = {
        name = cursorTheme;
        package = pkgs.apple-cursor;
        size = cursorSize;
        gtk.enable = true;
        x11.enable = true;
      };

      home.packages = [ pkgs.apple-cursor ];

      home.sessionVariables = {
        XCURSOR_THEME = cursorTheme;
        XCURSOR_SIZE = toString cursorSize;
      };

      gtk = {
        enable = true;
        cursorTheme = {
          name = cursorTheme;
          package = pkgs.apple-cursor;
          size = cursorSize;
        };
      };

      dconf = {
        enable = true;
        settings."org/gnome/desktop/interface" = {
          cursor-theme = cursorTheme;
          cursor-size = cursorSize;
        };
      };
    };
}
