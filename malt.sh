#!/bin/bash

# Malt!
# A script to check for certain package updates using brew,
# and updating them automatically if they are outdated.

# Author   : Tyler Dunneback
# Created  : Tue Dec 27, 2022
# Modified : Fri Dec 30, 2022

# Initialize packages to check for updates
while IFS= read -r line ; do
	all_packages+=("${line}")
done < <(brew list)

# Helper function to ask user to update their packages
function yes_or_no {
    outdated="$1[@]"; local arr=("${!outdated}")

    if [ "${#arr[@]}" -eq 1 ] ; then
        echo "You have 1 outdated package:"
    else
        echo "You have %s outdated packages:" "${#arr[@]}" 
    fi
    for package in "${arr[@]}" ; do
        tput bold; tput setaf 1
        echo "${package}"
        tput sgr0
    done
    echo

    while true ; do
        read -rp "Would you like to update these packages? [y\n]: " yn
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

    for package in "${arr[@]}" ; do
        if echo "${outdated_cmd}" | grep -Eq "${package}" ; then
            tput bold; tput setaf 1
            printf "[-] %s is outdated.\n" "${package}" 
            tput sgr0
            outdated_packages+=("${package}")
            sleep 0.1
        else
            tput setaf 2
            printf "[+] %s is up to date.\n" "${package}" 
            tput sgr0
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
    echo "usage: malt [-h | -a | -s package_name ...]" 1>&2; exit 1;
}

# Options menu if no arguments are passed
if [ ${#} -eq 0 ] ; then
    options_menu
fi

# User specifies with flags what packages to check
while getopts "has" arg ; do
    case "${arg}" in
        h)
            help_menu
            exit 0
            ;;
        a)
            echo "Checking for outdated packages..."
            echo "--------------------------------------------------"
            check_for_updates all_packages
            ;;
        s)
            echo "Checking for outdated packages..."
            echo "--------------------------------------------------"
            shift $((OPTIND - 1))
            user_packages_to_check=("${@}")
            for package in "${user_packages_to_check[@]}" ; do
                if echo "${all_packages[@]}" | grep -Eq "${package}" ; then
                    specific_packages_to_check+=("${package}")
                else
                    tput setaf 3
                    printf "[!] %s does not exist or is not installed.\n" "${package}" 
                    tput sgr0
                    sleep 0.1
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
if [ "${#outdated_packages[@]}" -gt 0 ] ; then
    yes_or_no outdated_packages
    sleep 0.5 
else
    printf "No packages require updating at this time...\n\n"
    sleep 0.5 
fi

goodbye_messages=("Hack and be merry!" "Happy hacking!" "Hack away, hack away!")
random_goodbye_index=$(( RANDOM % ${#goodbye_messages[@]} ))

echo "--------------------------------------------------"
printf "%s\n\n" "${goodbye_messages[random_goodbye_index]}"
exit 0
