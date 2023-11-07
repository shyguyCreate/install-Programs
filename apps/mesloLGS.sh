#!/bin/sh

program_name="MesloLGS-NF"
program_file="mesloLGS"
repo="ryanoasis/nerd-fonts"
program_type="font"

#Source file with functions
. "$(dirname "$0")/../.check-install.sh"

#Source file with functions
. "$(dirname "$0")/../.install.sh"

#Regex match when program is independent of architecture
download_all_arch='Meslo\.tar\.xz'

#Download release file
download_program

#Send download contents to install directory (optional flags)
send_to_install_dir

#BIN: Specify the program binary location
#FONT: Specify which fonts should be kept
install_program "MesloLGSNerdFont-*.ttf"

#Uninstall old program version
uninstall_old_version
