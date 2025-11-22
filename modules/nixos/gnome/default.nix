{ pkgs, ... }:
{
  services.xserver = {
    xkb.options = "caps:swapescape";
    enable = true;
  };
  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
    ])
    ++ (with pkgs; [
      epiphany # web browser
    ]);
  environment.systemPackages = with pkgs; [
    spotify
    # spotifywm
  ];
}
