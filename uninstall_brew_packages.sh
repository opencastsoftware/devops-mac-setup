#!/bin/bash

echo -e "Uninstalling packages installed by the \e[1;34msetup.sh\e[0 script..."

# Load the package lists from the external file
source packages/brew_packages.sh || { echo "Failed to load brew package list"; exit 1; }
#This has been added as it throws an error while removing cask
PrivilegesCLI --add

# Uninstall formulas
for formula in "${formulas[@]}"; do
    if brew list --formula | grep -q "^$formula$"; then
        brew uninstall "$formula"
    else
        echo "Skipping $formula, not installed."
    fi
    #This has been added so that ruby is removed even if there are dependencies
    if [ $? -eq 1 ]; then
      brew uninstall -ignore-dependencies "$forumula"
    fi
done

# Uninstall casks
for cask in "${casks[@]}"; do
    if brew list --cask | grep -q "^$cask$"; then
        brew uninstall --cask "$cask"
    else
        echo "Skipping $cask, not installed."
    fi
    if [[ $? == 1 ]]; then
      brew remove --force --cask "$cask"
    fi
done

# Cleanup unnecessary dependencies
brew cleanup

#This has been added as it throws an error while removing cask
PrivilegesCLI --remove

echo -e "All packages installed by the \e[1;34msetup.sh\e[0 script have been removed!"
