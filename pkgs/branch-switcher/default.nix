{ pkgs, ... }:
pkgs.writeScriptBin "branch-switcher" ''
  #!${pkgs.bash}/bin/bash

  if [[ $# -eq 1 ]]; then
      selected=$1
  else
      selected=$(git branch --all --format='%(refname:short)' | fzf)
  fi

  if [[ -z $selected ]]; then
      exit 0
  fi

  selected_name=$(basename "$selected")

  git checkout $selected_name 
''

