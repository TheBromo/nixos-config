{ ... }:
{
  flake.homeModules.kubernetes =
    { lib, pkgs, ... }:
    {

      home.packages = [
        pkgs.k9s
        pkgs.kubectl
        pkgs.kubectx
        pkgs.kubectl-neat
        pkgs.kubectl-example
        pkgs.kind
        (lib.lowPrio pkgs.minikube)
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
