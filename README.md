# devops-mac-setup
## Introduction

 This repo is intended to provide a helper script to speed up and automate the setup of MacOs primarily for DevOps Engineers, but also Developers who intend on using <span style="color: green;">AWS, Docker.</span> and <span style="color: green;">Node.js</span>.

The setup script will install the Brew package manager and then proceed to install various brew formulas, casks and taps based on <a href="https://opencastsoftware.atlassian.net/wiki/spaces/OCOS/pages/2611511305/Onboarding+Guide+For+New+Team+Members"> our Confluence documentation page</a>, along with the option of configuring `git` integration with our Opencast GitHub; allowing the user to commit code via `git`.

This script will also install various <span style="color: blue;">VS Code Extensions</span> referenced in the above documentation. The list of extensions used by the script is defined in [`packages/vscode_extensions.sh`](packages/vscode_extensions.sh).

---

## Usage

To run the startup script, either clone this repo to run the script locally (via HTTPS, assuming SSH Tokens are still to be setup for OC):
```
git clone https://github.com/opencastsoftware/devops-mac-setup.git
cd devops-mac-setup
bash ./setup.sh
```
or run directly from this repo, assuming `curl` is installed.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/opencastsoftware/devops-mac-setup/HEAD/setup.sh)"
```

### dry-run mode

Although fairly limited in scope, this project allows for usage of dry run mode.

```
bash ./setup.sh --dry-run
```
**Note** this will output a log file to your current directory `dry-run.log`.

This allows a mocked run of the script as a check. **Note** this can also be used to check GitHub login for existing credentials.

---

## Contributing to this Project

<blockquote style="background-color: lightblue; color: darkblue;">
<strong>Note:</strong>
This repository uses <code>npm</code> to manage dependencies.
</blockquote>


The scripts which get triggered via ```pre-commit``` and ```commit``` hooks. This ensures all commits are tested according to Opencast's standards. A full list of scripts can be found in ```package.json```, but the core scripts to be aware of are:

Used to run the latest commit against the `main` branch:
```
npm run prod
```
Used to format and lint project:
```
npm run lint:fix
```
Runs when you commit:
```
npm run test
```
Run to increment the commit tag and bump the version in the ```package.json```:
```
npm run release
```

### Adding brew packages or VS Code Extensions

Both `brew` packages and `VS Code Extensions` can be amended by the respective lists located in this project repository:

[`packages/brew_packages.sh`](packages/brew_packages.sh)

[`packages/vscode_extensions.sh`](packages/vscode_extensions.sh)

This can also be amended locally to install a customised setup specific to the user's requirements.

**Note:** the required syntax/naming convention for VS Code extensions is the marketplace identifier.

**e.g.**
`""hashicorp.terraform""`
for
**`HashiCorp Terraform`**

found under the VS Code marketplace.
