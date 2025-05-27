#!/bin/bash

set -e
# set -o inherit_errexit

################
# Setup script to configure MacOS tool chain for DevOps Engineers at Opencast Software.
################

version=$(grep '"version"' package.json | awk -F: '{print $2}' | sed 's/[",]//g' | tr -d '[:space:]') || { echo "Error reading version"; exit 1; }
echo "Running Script Version ${version}"

timestamp() {
	date +"%T" # current time
}

# Generic error handler
throw_error() {
    tput setaf 1
    error_time=$(timestamp)

    case "$BASH_COMMAND" in
        "source packages/brew_packages.sh")
            echo -e "ERROR | ${error_time} | Failed to load package lists. Ensure 'brew_packages.sh' exists and is accessible."
            ;;
        "source packages/vscode_extensions.sh")
            echo -e "ERROR | ${error_time} | Failed to load VS Code extensions. Ensure 'vscode_extensions.sh' exists and is accessible."
            ;;
        "brew bundle install")
            echo -e "ERROR | ${error_time} | Brew package installation failed. Check for missing dependencies or network issues."
            ;;
        "rm -f Brewfile.lock.json")
            echo -e "ERROR | ${error_time} | Failed to clean up Brewfile.lock.json. Check permissions."
            ;;
        "gh auth login --git-protocol ssh")
            echo -e "ERROR | ${error_time} | GitHub authentication failed. Verify your credentials and SSH setup."
            ;;
        "PrivilegesCLI --add")
            echo -e "ERROR | ${error_time} | Failed to elevate access using PrivilegesCLI. Try running manually."
            ;;
        "PrivilegesCLI --remove")
            echo -e "ERROR | ${error_time} | Failed to revoke privileges using PrivilegesCLI."
            ;;
        "source ~/.zprofile")
            echo -e "ERROR | ${error_time} | Failed to source ~/.zprofile. Check if the file exists."
            ;;
        "brew update")
            echo -e "ERROR | ${error_time} | Failed to update Homebrew. Ensure network connectivity."
            ;;
		"code --install-extension "*)
			extension_name=$(echo "$BASH_COMMAND" | awk '{print $NF}')

			tput setaf 1  # Set text color to red
			echo -e "ERROR | ${error_time} | Failed to install VS Code extension: \e[1;31m$extension_name\e[0m."
			tput sgr0  # Reset text formatting
			;;
        *)
            echo -e "ERROR | ${error_time} | Unexpected failure while executing: $BASH_COMMAND."
            ;;
    esac

    tput sgr0
    exit 1
}
trap 'throw_error' ERR


echo "Homebrew Package Manager Setup:"

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found, installing in user directory..."

	# adding privileges using Privileges App's CLI to install brew
	PrivilegesCLI --add

    # Run Homebrew installation
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
	source ~/.zprofile

    # Revoke privileges after installation
    PrivilegesCLI --remove

    # Update Homebrew
    brew update

else
    echo "Homebrew is already installed, skipping installation."
fi

# Load the package lists from the external file
source packages/brew_packages.sh

# Generate Brewfile dynamically
{
    for tap in "${taps[@]}"; do
        echo "tap \"$tap\""
    done

    for formula in "${formulas[@]}"; do
        echo "brew \"$formula\""
    done

    for cask in "${casks[@]}"; do
        echo "cask \"$cask\""
    done
} > Brewfile

# Install brew packages
brew bundle check || brew bundle install

# Cleanup Brewfile.lock.json
if [ -f Brewfile.lock.json ]; then
    rm -f Brewfile.lock.json
fi

 echo "Visual Studio Code Setup:"
# Load VS Code extensions from the external file
source packages/vscode_extensions.sh

# Install VS Code extensions dynamically
tput setaf 4 && echo "Configuring Visual Studio Code Extensions" && tput sgr0
for extension in "${vscode_extensions[@]}"; do
    code --install-extension "$extension"
done

tput setaf 2 && read -rp "Do you want to configure git now? yes[y]/no[n] " configure_git && tput sgr0

case "$(echo "$configure_git" | tr '[:upper:]' '[:lower:]')" in
    y|yes)
        my_username="$(whoami)" || throw_error "Failed to fetch system username."
        formatted_username=$(echo "${my_username}" | sed -r 's/[.]/ /g' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); } 1')

        git config --replace-all --global user.name "${formatted_username}"
        git config --replace-all --global user.email "${my_username}@opencastsoftware.com"

        git_config_output=$(git config --list)
        printf "Git configured with credentials:\n%s\n" "$git_config_output"

		echo "Choose your preferred Git editor:"
		select editor in "VS Code" "Vim" "Nano" "Skip"; do
			case $editor in
				"VS Code")
					git config --global core.editor "code -w"
					echo "VS Code set as default Git editor."
					break
					;;
				"Vim")
					git config --global core.editor "vim"
					echo "Vim set as default Git editor."
					break
					;;
				"Nano")
					git config --global core.editor "nano"
					echo "Nano set as default Git editor."
					break
					;;
				"Skip")
					echo "Skipping editor setup."
					break
					;;
				*)
					echo "Invalid option, please try again."
					;;
			esac
		done

        git config --global init.defaultBranch main

        tput setaf 4 && read -rp "Please ensure that you have a GitHub account associated with your Opencast credentials. Would you like to test the connection now? yes[y]/no[n] " git_login && tput sgr0
        case "$(echo "$git_login" | tr '[:upper:]' '[:lower:]')" in
            y|yes)
                gh config set git_protocol ssh
                gh auth login --git-protocol ssh

                echo "Git credentials configured! Please check GitHub in your browser, copy and paste the above confirmation code."
                echo -e "\n\nWhen we are all happy, please follow the instructions here \e[1;34mhttps://opencastsoftware.atlassian.net/wiki/spaces/OCOS/pages/2611511305/Onboarding+Guide+For+New+Team+Members#Local-administrator-rights\e[0m to setup GPG signing on your \e[1;34mgit commits\e[0m."
                ;;
            n|no)
                echo "Skipping GitHub connection test."
                ;;
            *)
                echo "Invalid choice, skipping GitHub setup."
                ;;
        esac
        ;;
    n|no)
        echo "Skipping Git configuration."
        ;;
    *)
        echo "Invalid choice, skipping Git setup."
        ;;
esac
