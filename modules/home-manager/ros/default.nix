{ ... }:
{
  flake.homeModules.ros =
    { ... }:
    {
      programs.zsh.initContent = ''
        export ROS_DOMAIN_ID=0
      '';
    };
}
