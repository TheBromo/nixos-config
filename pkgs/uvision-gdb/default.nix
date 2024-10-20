{ pkgs, ... }:
pkgs.writeScriptBin "uvision-gdb" ''
    #!${pkgs.bash}/bin/bash
    # uvision-gdb for Keil uVision
    # parameters:
    # $1: Filename of linker outputfile without path and without extension (Keil: @L)
    # $2: relative path to linker outputfile (e.g. "build")
    st-util&

    gdbgui_0.13.2.1 -g gdb-multiarch --gdb-args="--command=run.gdb" $2/$1&

    sleep 1
    google-chrome-stable localhost:5000&

    read -p "Press enter to close" k
''

