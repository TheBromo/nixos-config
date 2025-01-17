{pkgs,lib,...}:{
	home.packages =[
		pkgs.neovim
		pkgs.git
	];

	  home.activation = {
    configureNvim = lib.mkAfter ''
      mkdir -p ~/.config/nvim
      if [ -z "$(ls -A ~/.config/nvim)" ] || [ ! -d ~/.config/nvim/.git ]; then
	${pkgs.git}/bin/git clone https://github.com/TheBromo/neovim-config.git ~/.config/nvim
      else
        echo "Neovim configuration already exists. Skipping clone."
      fi
#      chown -R manuel:manuel ~/.config/nvim
      chmod -R u+w ~/.config/nvim
    '';
  };
}

