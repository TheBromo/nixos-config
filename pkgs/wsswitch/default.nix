{ pkgs, ... }:
pkgs.writeScriptBin "wsswitch" ''
  #!${pkgs.bash}/bin/bash

  if [[ $# -eq 1 ]]; then
      selected=$1
  else
      selected=$(
          {
              find ~/Development/ -mindepth 1 -maxdepth 1 -type d
              echo "$HOME/.config/nvim/"
          } | fzf
      )
  fi

  if [[ -z $selected ]]; then
      exit 0
  fi

  echo "$selected"
''
