{ pkgs, ... }:
{
  services.xserver = {
    xkb.options = "caps:swapescape";
    enable = true;
  };
  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  environment.gnome.excludePackages = [
    pkgs.gnome-photos
    pkgs.gnome-tour
    pkgs.epiphany # web browser
  ];
  environment.systemPackages = [
    pkgs.spotify
    # spotifywm
  ];
}
