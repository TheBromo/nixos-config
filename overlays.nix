{
  neovim-config,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      neovim = neovim-config.packages.${final.system}.default;
      # gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
      #   mutter = gnomePrev.mutter.overrideAttrs (old: {
      #     src = pkgs.fetchFromGitLab  {
      #       domain = "gitlab.gnome.org";
      #       owner = "vanvugt";
      #       repo = "mutter";
      #       rev = "triple-buffering-v4-46";
      #       hash = "sha256-C2VfW3ThPEZ37YkX7ejlyumLnWa9oij333d5c4yfZxc=";
      #     };
      #   });
      # });
    })
  ];
}
