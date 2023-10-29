#!/bin/sh

program_name="Github-Cli"
program_file="gh"
repo="cli/cli"

download_match='gh_.*_linux_amd64\.tar\.gz'
download_file=''
program_tmp_file="/tmp/$program_file.tar.gz"

#Source file with functions
. "$(dirname "$0")/.install.sh"

program_binary="$installDir/bin/$program_file"

#Install and uninstall
extract_program "--strip-components=1"
change_program_permission
install_program
add_old_Cobra_completions
uninstall_old_version
