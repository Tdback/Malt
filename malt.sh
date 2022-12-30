#!/bin/bash

# Malt!
# A script to check for certain package updates using brew,
# and updating them automatically if they are outdated.

# Author   : Tyler Dunneback
# Created  : Tue Dec 27, 2022
# Modified : Fri Dec 30, 2022

# Specify packages to always check for updates
specific_packages_to_check=()
user_packages_to_check=()

# Initialize packages to check for updates
all_packages=($(echo $(brew list)))

# Helper function to ask user to update their packages
function yes_or_no {
    outdated=$1[@]; local arr=("${!outdated}")

    while true ; do
        echo "--------------------------------------------------"
        read -p "Would you like to update these packages? [y\n]: " yn
        echo "--------------------------------------------------"
        case $yn in
            [Yy]) echo "Updating packages..."
                  brew upgrade "${arr[@]}";
                  printf "\nUpdate complete!\n\n";
                  break;;
            [Nn]) printf "Update aborted...\n\n";
                  break;;
            *) echo "Please enter 'y' or 'n'";;
        esac
    done
}

# Checks for updates for packages passed in based on flags used
function check_for_updates {
    outdated_cmd=$(brew outdated)

    packages_to_check=$1[@]; local arr=("${!packages_to_check}")

    for package in "${arr[@]}" ; do
        if echo "${outdated_cmd}" | grep -Eq "${package}" ; then
            printf " \xE2\x9D\x8C  ${package} is outdated.\n"
            outdated_packages+=("${package}")
            sleep 0.1
        else
            printf " \xE2\x9C\x94  ${package} is up to date.\n"
            sleep 0.1
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
    printf "usage: malt [-h | -a | -s package_name ...]\n"
}

# User specifies with flags what packages to check
if [ $# -eq 0 ] ; then
    options_menu
    exit 0

elif [ "$1" = "-a" ] ; then
    echo "Checking for outdated packages..."
    echo "--------------------------------------------------"
    check_for_updates all_packages

elif [ "$1" = "-s" ] ; then
    echo "Checking for outdated packages..."
    echo "--------------------------------------------------"
    shift
    while [ $# -gt 0 ] ; do
        user_packages_to_check+=("$1")
        shift
    done
    for package in "${user_packages_to_check[@]}" ; do
        if echo "${all_packages[@]}" | grep -Eq "${package}" ; then
            specific_packages_to_check+=("${package}")
        else
            printf "|!| ${package} does not exist or is not installed.\n"
            sleep 0.1
        fi
    done
    check_for_updates specific_packages_to_check

elif [ "$1" = "-h" ] || [ "$1" = "-help" ] ; then
    help_menu
    exit 0
fi

echo 

# Prompt user to updated outdated packages OR exit early
# if no packages need updating.
if [ ${#outdated_packages[@]} -gt 0 ] ; then
    yes_or_no outdated_packages
    sleep 0.5 

    else
    printf "No packages require updating at this time...\n\n"
    sleep 0.5 
fi

goodbye_messages=("Hack and be merry!\n\n" "Happy hacking!\n\n" "Hack away, hack away!\n\n")
random_goodbye_index=$(( $RANDOM % ${#goodbye_messages[@]} ))

echo "--------------------------------------------------"
printf "${goodbye_messages[random_goodbye_index]}"
exit 0
