{ self, inputs, ... }:
{
  flake.homeModules.ros =
    { pkgs, ... }:
    {

      programs.zsh.initContent = ''
        export ROS_DOMAIN_ID=0
      '';
    };
}
