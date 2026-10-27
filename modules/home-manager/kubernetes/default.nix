{ ... }:
{
  flake.homeModules.kubernetes =
    { pkgs, ... }:
    {

      home.packages = [
        pkgs.k9s
        pkgs.kubectl
        pkgs.kubectx
        pkgs.kubectl-neat
        pkgs.kubectl-example
        pkgs.kind
        pkgs.cilium-cli
        pkgs.kubernetes-helm
      ];

      home.shellAliases.k = "kubectl";

      programs.bash.initExtra = ''
        source <(kubectl completion bash)
      '';
      programs.zsh.initContent = ''
        source <(kubectl completion zsh)
      '';
    };
}
