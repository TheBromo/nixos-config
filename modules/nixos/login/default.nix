{ pkgs, inputs, ... }:
let
  tuigr = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  #  hyprland-session = "${inputs.hyprland.packages.${pkgs.system}.hyprland}/share/wayland-sessions";
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${tuigr}\
          --time \
          --asterisks \
          --user-menu \
          --cmd Hyprland
      '';
      #      hyprland.command = ''
      #        "${tuigreet} --time --remember --remember-session --sessions ${hyprland-session}";
      #      '';
    };
  };
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
  environment.etc."greetd/environments".text = ''
    Hyprland
  '';
  #   hyprland
}

