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
	error_time=$(timestamp) || { echo "Error fetching timestamp"; exit 1; }
	echo -e "ERROR| ${error_time} | ${1}"
	tput sgr0
	exit 1
}

echo "Homebrew Package Manager Setup:"

if ! command -v brew &>/dev/null; then
    echo "Homebrew not found, installing in user directory..."

	# adding privileges using Privileges App's CLI to install brew
	PrivilegesCLI --add || throw_error "failed to elevate access."

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
source packages/brew_packages.sh || throw_error "Failed to load package lists"

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
} > Brewfile || throw_error "Failed to create Brewfile"

# Install brew packages
brew bundle check || brew bundle install || throw_error "Failed to install missing brew packages"

# Cleanup Brewfile.lock.json
if [ -f Brewfile.lock.json ]; then
    rm -f Brewfile.lock.json
fi

 echo "Visual Studio Code Setup:"
# Load VS Code extensions from the external file
source packages/vscode_extensions.sh || throw_error "Failed to load VS Code extensions"

# Install VS Code extensions dynamically
tput setaf 4 && echo "Configuring Visual Studio Code Extensions" && tput sgr0
for extension in "${vscode_extensions[@]}"; do
    code --install-extension "$extension" || throw_error "Failed to install $extension"
done

tput setaf 2 && read -rp "Do you want to configure git now? yes[y]/no[n]" configure_git && tput sgr0

if [[ "$(echo "$configure_git" | tr '[:upper:]' '[:lower:]')" =~ ^(y|yes)$ ]]; then
	declare my_username
	my_username="$(whoami)"
	formatted_username=$(echo "${my_username}" | sed -r 's/[.]/ /g' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); } 1') || throw_error "Error formatting username"

	git config --replace-all --global user.name "${formatted_username}" || { echo "Failed to configure Git username"; exit 1; }

	git config --replace-all --global user.email "${my_username}@opencastsoftware.com"

	git_config_output=$(git config --list)
	printf "Git configured with credentials:\n%s\n" "$git_config_output"

	tput setaf 4 && read -rp "   Do you want to use VS Code as your default IDE (Yes [y]/No [n])? " default_IDE && tput sgr0
	if [[ "$(echo "$default_IDE" | tr '[:upper:]' '[:lower:]')" =~ ^(y|yes)$ ]]; then

		git config --global core.editor "code -w"
	fi

	git config --global init.defaultBranch main
	tput setaf 4 && read -rp "Please ensure that you have a GitHub account associated with your Opencast credentials. Would you like to test the connection now? yes[y]/no[n]" git_login && tput sgr0
	if [[ "$(echo "$git_login" | tr '[:upper:]' '[:lower:]')" =~ ^(y|yes)$ ]]; then

		gh config set git_protocol ssh
		gh auth login --git-protocol ssh || throw_error "Github Login Failed"

		echo "Git credentials configured! Please check GitHub in your browser, copy and pasting the above confirmation code."
		echo -e "\n\nWhen we are all happy, please follow the instructions here \e[1;34mhttps://opencastsoftware.atlassian.net/wiki/spaces/OCOS/pages/2611511305/Onboarding+Guide+For+New+Team+Members#Local-administrator-rights\e[0m to setup GPG signing on your \e[1;34mgit commits\e[0m."
	fi
fi
