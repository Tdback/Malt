#!/usr/bin/env bash

# ==============================================================================
#
#   Author  : Tyler Dunneback
#   Date    : April 10, 2023
#   GitHub  : https://github.com/Tdback
#   Version : 1.3
#
# ==============================================================================

#  A front-end wrapper for the brew package updater, which checks for outdated 
#+ packages and prompts a user to perform upgrades on any outdated packages it 
#+ finds. Users can also specify individual packages they wish to upgrade.


# Initialize packages to check for updates
while IFS= read -r line; do
  all_packages+=("${line}")
done < <(brew list)

# Helper function to ask user to update their packages
function yes_or_no {
  outdated="$1[@]"; local arr=("${!outdated}")

  if [ "${#arr[@]}" -eq 1 ]; then
    echo "You have 1 outdated package:"
  else
    printf "You have %s outdated packages:\n" "${#arr[@]}" 
  fi

  # Print out packages in a matrix for readability
  num=0
  tput bold; tput setaf 1
  for package in "${arr[@]}"; do
    printf "  %s  " "${package}"
    (( num+=${#package} ))
    if [ "${num}" -ge 50 ]; then
      printf "\n"	
      num=0
    fi
  done
  tput sgr0

  echo

  # Prompt user to update packages
  while :; do
    read -rp "Would you like to update these packages? [y/n]: " yn
    case $yn in
      [Yy]) brew upgrade "${arr[@]}";
        printf "\nUpdate complete!\n\n";
        break
	;;
      [Nn]) printf "\nUpdate aborted...\n\n";
        break
	;;
      *) echo "Please enter 'y' or 'n'"
	;;
    esac
  done
}

# Checks for updates for packages passed in based on flags used
function check_for_updates {
  outdated_cmd=$(brew outdated)

  packages_to_check="$1[@]"; local arr=("${!packages_to_check}")

  for package in "${arr[@]}"; do
    if echo "${outdated_cmd}" | grep -Eq "${package}"; then
      tput bold; tput setaf 1
      printf "[-] %s is outdated.\n" "${package}" 
      tput sgr0
      outdated_packages+=("${package}")
      sleep 0.05
    else
      tput setaf 2
      printf "[+] %s is up to date.\n" "${package}" 
      tput sgr0
      sleep 0.05
    fi
  done
}

function help_menu {
  printf "Welcome to Malt, the Brew package updater!
  -h : Help page.
  -a : Check all packages for updates.
  -s : Check specific packages for updates.\n"
}

function options_menu {
  echo "usage: malt [-h | -a | -s package_name ...]" 1>&2; exit 1;
}

# Options menu if no arguments are passed
if [ ${#} -eq 0 ]; then
  options_menu
fi

# User specifies with flags what packages to check
while getopts "has" arg; do
  case "${arg}" in
    h)
      help_menu
      exit 0
      ;;
    a)
      echo "Checking for outdated packages..."
      printf "%.0s-" {1..80} && echo
      check_for_updates all_packages
      ;;
    s)
      echo "Checking for outdated packages..."
      printf "%.0s-" {1..80} && echo
      shift $((OPTIND - 1))
      user_packages_to_check=("${@}")
      for package in "${user_packages_to_check[@]}"; do
        if echo "${all_packages[@]}" | grep -Eq "${package}"; then
          specific_packages_to_check+=("${package}")
        else
          tput setaf 3
          printf "[!] %s does not exist or is not installed.\n" "${package}" 
          tput sgr0
      	  sleep 0.05
        fi
      done
      check_for_updates specific_packages_to_check
      ;;
    \?)
      echo "Invalid option. For help or to view Malt's options, use \"-h\"."
      exit 2
      ;;
  esac
done
echo 

# Prompt user to updated outdated packages OR exit early
# if no packages need updating.
if [ "${#outdated_packages[@]}" -gt 0 ]; then
  yes_or_no outdated_packages
  sleep 0.25 
else
  printf "No packages require updating at this time...\n\n"
  sleep 0.25 
fi

goodbye_messages=("Hack and be merry!" "Happy hacking!" "Hack away, hack away!")
random_goodbye_index=$(( RANDOM % ${#goodbye_messages[@]} ))

printf "%.0s-" {1..80} && echo
printf "%s\n\n" "${goodbye_messages[random_goodbye_index]}"
exit 0
