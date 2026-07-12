{ ... }:
{
  flake.homeModules.zedCyberdream = {
    home.file.".config/zed/themes/cyberdream-custom.json".source = ./cyberdream-custom.json;
  };
}
