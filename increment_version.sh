#!/bin/bash
if [[ "$(git rev-parse --abbrev-ref HEAD)" == "main" ]]; then
	read -rp "Enter commit message: " commit_message &&
		auto-version --minor &&
		git add . && git commit -am "$commit_message" &&
		git tag "$(cat package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | tr -d '[[:space:]]')"
	git push
fi
