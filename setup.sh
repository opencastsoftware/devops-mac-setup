#!/bin/bash
timestamp() {
  date +"%T" # current time
}
throw_error () {
    RED='\033[0;31m';
    NC='\033[0m';
    echo -e "${RED}ERROR| $(timestamp) | ${1} ${NC}\n";
    sleep 5;
    exit 1
}
/bin/bash -c  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || throw_error "Failed to run brew installer; check you have admin permissions, exiting"

echo 'tap "hashicorp/tap"
tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/core"
tap "homebrew/cask-drivers"
tap "microsoft/git"
tap "warrensbox/tap"
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
cask "docker"
cask "github"
cask "visual-studio-code"
cask "postman"
cask "git-credential-manager-core"


' > Brewfile && brew bundle || throw_error "Failed to install brew bundle"
echo "Configuring Visual Studio Code Extensions"
code    --install-extension aslamanver.vsc-export \
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
        --install-extension trunk.io || throw_error "Error: One or more visual studio extensions failed to install"

read -p "Do you want to configuring git now? press enter to contine......."

git config --global user.name $(whoami | sed -r 's/[.]/ /g' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')
git config --global user.email "${$(whoami)}@opencastsoftware.com"
read -p "?Do you want to use vs code as your default IDE (Yes [y]/No [n])? " default_IDE
if [[ $default_IDE == "y" ]]; then 
    git config --global core.editor "code -w";
fi
git config --global init.defaultBranch main

read -p "? Please signup for a github account using your opencast credentials before you continue" && \
gh auth login || throw_error "Github Login Failed"