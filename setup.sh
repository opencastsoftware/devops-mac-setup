#!/bin/bash

################
# Setup script to configure MacOs tool chain for DevOps Engineers in Opencast Software
################
echo "Running Script Version $(cat package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')"
timestamp() {
	date +"%T" # current time
}
throw_error() {
	tput setaf 1
	echo -e "ERROR| $(timestamp) | ${1}"
	tput sgr0
	exit 1
	sleep 5
}
/Applications/Privileges.app/Contents/Resources/PrivilegesCLI --add || throw_error "failed to elevate access"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || throw_error "Failed to install brew"

echo 'tap "hashicorp/tap"
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"
tap "homebrew/cask-drivers"
tap "microsoft/git"
tap "warrensbox/tap"
brew "helm"
brew "python@3.10"
brew "ansible"
brew "awscli"
brew "cdk"
brew "gh"
brew "git"
brew "iproute2mac"
brew "netcat"
brew "node"
brew "pre-commit"
brew "volta"
brew "warrensbox/tap/tfswitch"
brew "tfswitch"
brew "kubectl"
brew "docker-compose"
brew "jq"
brew "openssl"
brew "gnupg"
brew "ruby"
cask "docker"
cask "github"
cask "visual-studio-code"
cask "postman"
cask "git-credential-manager-core"
' >Brewfile || throw_error "Failed to create bundle file"
brew bundle || throw_error "Failed to install brew bundle" && rm -f Brew*
tput setaf 4 && echo "Configuring Visual Studio Code Extensions" && tput sgr0
code --install-extension aslamanver.vsc-export \
	--install-extension ban.spellright \
	--install-extension Bridgecrew.checkov \
	--install-extension DavidAnson.vscode-markdownlint \
	--install-extension eamodio.gitlens \
	--install-extension EditorConfig.EditorConfig \
	--install-extension GitLab.gitlab-workflow \
	--install-extension hashicorp.terraform \
	--install-extension ms-azuretools.vscode-docker \
	--install-extension ms-kubernetes-tools.vscode-kubernetes-tools \
	--install-extension ms-vscode-remote.remote-ssh \
	--install-extension ms-vscode-remote.remote-ssh-edit \
	--install-extension pjmiravalle.terraform-advanced-syntax-highlighting \
	--install-extension redhat.vscode-yaml \
	--install-extension run-at-scale.terraform-doc-snippets \
	--install-extension trunk.io --force --log off || throw_error "Error: One or more visual studio extensions failed to install"

tput setaf 2 && read -rp "Do you want to configuring git now yes[y]/no[n]? " configure_git && tput sgr0
if [[ "$configure_git" == "y" || "$configure_git" == "yes" ]]; then
	declare my_username
	my_username="$(whoami)"
	git config --replace-all --global user.name "$(echo "${my_username}" | sed -r 's/[.]/ /g' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')"
	git config --replace-all --global user.email "${my_username}@opencastsoftware.com"

	tput setaf 4 && read -rp "   Do you want to use vs code as your default IDE (Yes [y]/No [n])? " default_IDE && tput sgr0
	if [[ $default_IDE == "yes" || $default_IDE == "y" ]]; then
		git config --global core.editor "code -w"
	fi
	git config --global init.defaultBranch main
	tput setaf 4 && read -rp "    Please signup for a github account using your opencast credentials before you continue yes[y]/no[n]? " git_login && tput sgr0
	if [[ "$git_login" == "yes" || "$git_login" == "y" ]]; then
		gh auth login || throw_error "Github Login Failed"
	fi
fi
/Applications/Privileges.app/Contents/Resources/PrivilegesCLI --remove
