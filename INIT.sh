#!/usr/bin/env bash

if [[ -f ".git/PROJECT_INITIALIZED" ]]; then
	echo "This repository has already been initialized, skipping..."
	exit 0
fi

echo "git rev-parse --short HEAD > GIT_HASH.txt" >> ".git/hooks/pre-push"
bash -c .git/hooks/pre-push

touch .git/PROJECT_INITIALIZED
