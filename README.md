# devops-mac-setup
<h1> Introduction</h1>
<p> This repo is intended to provide a helper script to speed up and automate the setup of MacOs primarily for DevOps engineers, but also Developers using AWS,Docker and Node</p>
<br>
<p>The setup script will install various brew formula's, casks and taps based on documentation <a href="https://opencastsoftware.atlassian.net/wiki/spaces/OCOS/pages/2611511305/Onboarding+Guide+For+New+Team+Members"> Here</a>, along with configuring git intregration with Github</p>
<hr>
<br>
<h1>Usage</h1>

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/opencastsoftware/devops-mac-setup/HEAD/setup.sh)"
```

<h1>Contributing</h1>
<p>This repository uses npm to manage dependancies and scripts which get triggered via pre-commit and commit hooks. This ensures all commits are tested according to industry standards. <br> You can find a full list of scripts in package.json, but the main ones to be aware of are;

Used to run the latest commit against main
```
npm run prod
```
Used to format and lint project
```
npm run lint:fix
```
Runs when you commit
```
npm run test
```
Run to increment the commit tag and bump the version in the package.json
```
npm run release
```
