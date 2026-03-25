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
        pkgs.minikube
        pkgs.cilium-cli
        pkgs.kubernetes-helm
      ];

      programs.zsh = {
        shellAliases = {
          k = "kubectl";
        };

        initContent = ''
          source <(kubectl completion zsh)
        '';
      };
    };
}
