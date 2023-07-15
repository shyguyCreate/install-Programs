#!/bin/sh

program="MesloLGS-NF"

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
tag_tmp_file="/tmp/tag_name_mesloLGS"
if [ ! -f "$tag_tmp_file" ] || [ $refreshFlag = true ] || [ $forceFlag = true ]
then
  curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest \
  | grep tag_name \
  | cut -d \" -f 4 \
  | xargs > "$tag_tmp_file"
fi

#Save tag_name to variable
tag_name=$(cat "$tag_tmp_file")
#Set the install directory with github tag added to its name
installDir="/usr/local/share/fonts/mesloLGS $tag_name"


#Get the current version that is appended inside the folder name
current_version=$(find /usr/local/share -maxdepth 2 -mindepth 2 -type d -path "/usr/local/share/fonts/mesloLGS *" -printf '%f' -quit | awk '{print $2}')


#Start installation if github version is not equal to installed version
if [ "$tag_name" != "$current_version" ] && [ $checkFlag = false ] || [ $forceFlag = true ]
then
  echo "Downloading $program"

  #Download fonts
  curl -Lf --progress-bar https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -o /tmp/Meslo.zip

  #Remove fonts folder and older fonts if exist
  rm -rf /tmp/Meslo
  find /usr/local/share -maxdepth 2 -mindepth 2 -type d -path "/usr/local/share/fonts/mesloLGS *" -exec sudo rm -rf '{}' \+

  #Create folder for contents
  sudo mkdir -p "$installDir"

  printf "Begin %s installation..." "$program"

  #Extract fonts
  mkdir -p /tmp/Meslo
  unzip -q /tmp/Meslo.zip -d /tmp/Meslo

  #Install fonts globally
  sudo cp /tmp/Meslo/MesloLGSNerdFont-*.ttf "$installDir"

  [ -d "$installDir" ] && [ -n "$(ls "$installDir")" ] && printf "Finished\n" || printf "Failed\n"

elif [ $checkFlag = true ] && [ "$tag_name" = "$current_version" ]
then
  echo "No update found for $program"

elif [ $checkFlag = true ] && [ "$tag_name" != "$current_version" ]
then
  echo "Update found for $program"

else
  echo "$program is up to date"
fi
