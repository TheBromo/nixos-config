{ ... }:
{
  flake.nixosModules.gnome = {
    services.xserver.enable = false;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
  };
}
