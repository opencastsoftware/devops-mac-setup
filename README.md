# DevOps Mac Setup

This repository helps automate the setup of a developer workstation for DevOps and software engineering work on macOS. It installs common tooling, configures Git, and prepares a VS Code environment tailored for day-to-day engineering tasks.

## What this project does

The setup script installs and configures:

- Homebrew and package management
- commonly used developer tools and CLIs
- VS Code extensions
- Git configuration for the team environment
- optional GitHub authentication setup
- Podman machine setup for container-based workflows

The package list is managed in:

- [packages/brew_packages.sh](packages/brew_packages.sh)
- [packages/vscode_extensions.sh](packages/vscode_extensions.sh)

## Prerequisites

Before running the setup:

- macOS is required
- you should have administrator access
- internet access is required for package and tool installation
- you should have an Opencast GitHub account or equivalent GitHub access if you plan to authenticate GitHub from the script

## Quick start

Clone the repository and run the script:

```bash
git clone https://github.com/opencastsoftware/devops-mac-setup.git
cd devops-mac-setup
bash ./setup.sh
```

You can also run it directly from GitHub with curl:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/opencastsoftware/devops-mac-setup/HEAD/setup.sh)"
```

## Dry-run mode

A light dry-run mode is available to preview the commands without making changes:

```bash
bash ./setup.sh --dry-run
```

This writes output to a local `dry-run.log` file and is useful for checking what would run before making changes.

## Customising the setup

You can adjust the installed packages or VS Code extensions by editing:

- [packages/brew_packages.sh](packages/brew_packages.sh)
- [packages/vscode_extensions.sh](packages/vscode_extensions.sh)

The scripts are designed to support a standard developer environment, but you can tailor them to your own setup.

## Contributing

This repository is intended to support team onboarding and machine setup. Contributions are welcome if they improve reliability, usability, or developer experience.

The project uses npm-based tooling for project checks and release automation. Common commands include:

```bash
npm run test
npm run lint:fix
npm run release
```

For more detail, see [package.json](package.json).

## Notes

- This setup is primarily designed for macOS developer environments.
- Some configuration steps, such as GitHub authentication and privilege setup, may require interactive confirmation.
- The script is best used as a guided onboarding or workstation bootstrap tool rather than a fully unattended deployment system.
