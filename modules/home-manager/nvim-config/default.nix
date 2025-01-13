{pkgs,lib,...}:
let
  neovimConfigRepo = pkgs.fetchgit {
      url = "https://github.com/TheBromo/neovim-config.git";
    #rev = "310609e"; # Adjust to the correct branch or tag
      sha256 = "sha256-lUYYEhzOgViBw3dDrGytK1p53GEHTpvULYmsa6K3itk=";
  };

in
{
	home.packages =[
		pkgs.neovim
		pkgs.git
		pkgs.rsync
	];

	  home.activation = {
    configureNvim = lib.mkAfter ''
      # Ensure ~/.config/nvim exists
      mkdir -p ~/.config/nvim

      # Sync fetched repository to the directory if empty
      if [ ! -d ~/.config/nvim/.git ]; then
        ${pkgs.rsync}/bin/rsync -a ${neovimConfigRepo}/ ~/.config/nvim/
      fi

      # Set ownership and permissions for the 'manuel' user
      chown -R manuel:manuel ~/.config/nvim
      chmod -R u+w ~/.config/nvim
    '';
  };
}

