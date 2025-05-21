#!/bin/bash
set -e

echo "Uninstalling packages installed by this script..."

# Load the package lists from the external file
source packages/brew_packages.sh || { echo "Failed to load brew package list"; exit 1; }

# Uninstall formulas
for formula in "${formulas[@]}"; do
    if brew list --formula | grep -q "^$formula$"; then
        brew uninstall "$formula"
    else
        echo "Skipping $formula, not installed."
    fi
done

# Uninstall casks
for cask in "${casks[@]}"; do
    if brew list --cask | grep -q "^$cask$"; then
        brew uninstall --cask "$cask"
    else
        echo "Skipping $cask, not installed."
    fi
done

# Cleanup unnecessary dependencies
brew cleanup

echo "All packages installed by the script have been removed!"
