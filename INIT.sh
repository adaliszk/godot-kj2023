#!/usr/bin/env bash

if [[ -f ".git/PROJECT_INITIALIZED" ]]; then
	echo "This repository has already been initialized, skipping..."
	exit 0
fi

if [[ ! -f ".git/hooks/post-commit" ]]; then
	echo "Git LFS seems to be not initializted, please install LFS to this repository!"
	exit 1
fi

echo "git rev-parse --short HEAD > GIT_HASH.txt" >> ".git/hooks/post-commit"
bash -c .git/hooks/post-commit

touch .git/PROJECT_INITIALIZED
