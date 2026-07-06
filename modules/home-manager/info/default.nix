{ ... }:
{
  flake.homeModules.info =
    { pkgs, ... }:
    let
      info = pkgs.writeShellScriptBin "screenfetch" ''
        ## INFO
        host="$(hostname)"
        if [ -r /etc/os-release ]; then
            . /etc/os-release
            os="$PRETTY_NAME"
        elif [ "$(uname -s)" = "Darwin" ]; then
            os="$(sw_vers -productName) $(sw_vers -productVersion)"
        else
            os="$(uname -s) $(uname -r)"
        fi
        kernel="$(uname -sr)"
        uptime="$(uptime | awk -F, '{sub(".*up ",x,$1);print $1}' | sed -e 's/^[ \t]*//')"
        packages="$(ls -d -1 /nix/store/*/ | wc -l | tr -d ' ')"
        shell="$(basename "''${SHELL}")"

        ## UI DETECTION
        parse_rcs() {
            for f in "''${@}"; do
                wm="$(tail -n 1 "''${f}" 2> /dev/null | cut -d ' ' -f 2)"
                [ -n "''${wm}" ] && echo "''${wm}" && return
            done
        }

        rcwm="$(parse_rcs "''${HOME}/.xinitrc" "''${HOME}/.xsession")"

        ui='unknown'
        uitype='UI'
        if [ "$(uname -s)" = "Darwin" ]; then
            ui='Aqua'
            uitype='DE'
        elif [ -n "''${DE}" ]; then
            ui="''${DE}"
            uitype='DE'
        elif [ -n "''${WM}" ]; then
            ui="''${WM}"
            uitype='WM'
        elif [ -n "''${XDG_CURRENT_DESKTOP}" ]; then
            ui="''${XDG_CURRENT_DESKTOP}"
            uitype='DE'
        elif [ -n "''${DESKTOP_SESSION}" ]; then
            ui="''${DESKTOP_SESSION}"
            uitype='DE'
        elif [ -n "''${rcwm}" ]; then
            ui="''${rcwm}"
            uitype='WM'
        elif [ -n "''${XDG_SESSION_TYPE}" ]; then
            ui="''${XDG_SESSION_TYPE}"
        fi

        ui="$(basename "''${ui}")"

        ## DEFINE COLORS
        if [ -x "$(command -v tput)" ]; then
            bold="$(tput bold 2> /dev/null)"
            brblack="$(tput setaf 8 2> /dev/null)"
            red="$(tput setaf 1 2> /dev/null)"
            green="$(tput setaf 2 2> /dev/null)"
            yellow="$(tput setaf 3 2> /dev/null)"
            blue="$(tput setaf 4 2> /dev/null)"
            magenta="$(tput setaf 5 2> /dev/null)"
            cyan="$(tput setaf 6 2> /dev/null)"
            white="$(tput setaf 7 2> /dev/null)"
            reset="$(tput sgr0 2> /dev/null)"
        fi

        lc="''${reset}''${bold}"
        nc="''${reset}''${bold}"
        ic="''${reset}"
        c0="''${reset}''${brblack}"
        c1="''${reset}''${white}"
        c2="''${reset}''${yellow}"

        ## OUTPUT
        if [ "$(uname -s)" = "Darwin" ]; then
        cat <<FETCH

''${green}       .:'    ''${nc}''${USER}''${ic}@''${nc}''${host}''${reset}
''${green}    __:'__    ''${lc}OS:        ''${ic}''${os}''${reset}
''${c0} .'\`__\`-'__\`\`. ''${lc}KERNEL:    ''${ic}''${kernel}''${reset}
''${c0}:__________.-' ''${lc}UPTIME:    ''${ic}''${uptime}''${reset}
''${c0}:_________:    ''${lc}PACKAGES:  ''${ic}''${packages}''${reset}
''${c0} :_________\`-; ''${lc}SHELL:     ''${ic}''${shell}''${reset}
''${c0}  \`.__.-.__.'  ''${lc}''${uitype}:        ''${ic}''${ui}''${reset}

FETCH
        else
        cat <<FETCH

''${c0}      ___     ''${nc}''${USER}''${ic}@''${nc}''${host}''${reset}
''${c0}     (''${c1}.. ''${c0}\    ''${lc}OS:        ''${ic}''${os}''${reset}
''${c0}     (''${c2}<> ''${c0}|    ''${lc}KERNEL:    ''${ic}''${kernel}''${reset}
''${c0}    /''${c1}/  \ ''${c0}\   ''${lc}UPTIME:    ''${ic}''${uptime}''${reset}
''${c0}   ( ''${c1}|  | ''${c0}/|  ''${lc}PACKAGES:  ''${ic}''${packages}''${reset}
''${c2}  _''${c0}/\ ''${c1}__)''${c0}/''${c2}_''${c0})  ''${lc}SHELL:     ''${ic}''${shell}''${reset}
''${c2}  \/''${c0}-____''${c2}\/''${reset}   ''${lc}''${uitype}:        ''${ic}''${ui}''${reset}

FETCH
        fi
      '';
    in
    {
      home.packages = [
        info
      ];
    };
}
