{ pkgs, ... }:
pkgs.writeScriptBin "uvision-flash" ''
    #!${pkgs.bash}/bin/bash
    # uvision-flash for Keil uVision
    # parameters:
    # $1: Filename without path and without extension (Keil: @L)
    # $2: Adress (STM32F429: 0x08000000)

    echo converting $1.axf to $1.bin and $1.elf
    wine /data/PlayOnLinux/wineprefix/Keil/drive_c/Keil_v5/ARM/ARMCC/bin/fromelf.exe --bin --output $1.bin

    $1.axf
    echo flashing $1.bin to adress $2

    #flash CT-Board (STM32F429)
    st-flash write $1.bin $2

    read -p "Press enter to continue" k
''

