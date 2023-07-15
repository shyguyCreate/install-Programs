#!/bin/sh

program="VSCodium"

#Add flags to script
checkFlag=false
forceFlag=false
refreshFlag=false
while getopts ":cfy" opt; do
  case $opt in
    c) checkFlag=true ;;
    f) forceFlag=true ;;
    y) refreshFlag=true ;;
    *) echo "-c to check available updates"
       echo "-f to force installation"
       echo "-y to refresh github tag" ;;
  esac
done

#Reset getopts automatic variable
OPTIND=1


#Get latest tag_name
tag_tmp_file="/tmp/tag_name_codium"
if [ ! -f "$tag_tmp_file" ] || [ $refreshFlag = true ] || [ $forceFlag = true ]
then
  curl -s https://api.github.com/repos/VSCodium/vscodium/releases/latest \
  | grep tag_name \
  | cut -d \" -f 4 \
  | xargs > "$tag_tmp_file"
fi

#Save tag_name to variable
tag_name=$(cat "$tag_tmp_file")
#Set the install directory with github tag added to its name
installDir="/opt/codium $tag_name"


#Get the current version of the program
current_version=$(find /opt -maxdepth 1 -type d -name "codium *" -printf '%f' -quit | awk '{print $2}')


#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && [ $checkFlag = false ] || [ $forceFlag = true ]
then
  printf "Begin %s installation..." "$program"

  #Download binaries
  curl -s https://api.github.com/repos/VSCodium/vscodium/releases/latest \
  | grep "browser_download_url.*VSCodium-linux-x64-.*.tar.gz\"" \
  | cut -d \" -f 4 \
  | xargs curl -Lsf -o /tmp/codium.tar.gz

  if [ $? = 0 ]
  then
    #Remove contents if already installed
    find /opt -maxdepth 1 -type d -name "codium *" -exec sudo rm -rf '{}' \+

    #Create folder for contents
    sudo mkdir -p "$installDir"

    #Expand tar file to folder
    sudo tar zxf /tmp/codium.tar.gz -C "$installDir"

    #Change execute permissions
    sudo chmod +x "$installDir/bin/codium"

    #Create symbolic link to bin folder
    sudo mkdir -p /usr/local/bin
    sudo ln -sf "$installDir/bin/codium" /usr/local/bin

    #Add completions for bash
    sudo mkdir -p /usr/local/share/bash-completion/completions
    sudo cp "$installDir/resources/completions/bash/codium" /usr/local/share/bash-completion/completions

    #Add completions for zsh
    sudo mkdir -p /usr/local/share/zsh/site-functions
    sudo cp "$installDir/resources/completions/zsh/_codium" /usr/local/share/zsh/site-functions

    #Copy application image
    sudo mkdir -p /usr/local/share/pixmaps
    sudo cp "$installDir/resources/app/resources/linux/code.png" /usr/local/share/pixmaps/codium.png

    printf "Finished\n"
  else
    printf "Failed\n"
  fi

elif [ $checkFlag = true ] && [ "$tag_name" = "$current_version" ]
then
  echo "No update found for $program"

elif [ $checkFlag = true ] && [ "$tag_name" != "$current_version" ]
then
  echo "Update found for $program"

else
  echo "$program is up to date"
fi


#Check if .desktop file exist
if [ ! -f /usr/local/share/applications/codium.desktop ] && [ $checkFlag = false ] || [ $forceFlag = true ]
then
  #Write application .desktop file
  sudo mkdir -p /usr/local/share/applications
  echo \
  '[Desktop Entry]
  Name=VSCodium
  Comment=Free/Libre Open Source Software Binaries of VS Code
  GenericName=VSCodium
  Exec=/usr/local/bin/codium
  Icon=/usr/local/share/pixmaps/codium.png
  Categories=Utility;TextEditor;Development;IDE
  Type=Application' \
  | sed 's/^[ \t]*//' - | sudo tee /usr/local/share/applications/codium.desktop > /dev/null
fi
