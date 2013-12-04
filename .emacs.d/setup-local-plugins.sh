#!/usr/bin/env bash

cd "${0%/*}"

if [[ -d "bundle" ]]; then
	echo "Updating all"
	echo

	cd "bundle"

	for repo in *; do
		( cd "$repo" && git pull )
	done

else
	echo "Initial fetch"
	echo

	mkdir -p "bundle" || exit 1

	cd "bundle"

	repos=(
		"git://gitorious.org/evil/evil.git"
		"https://github.com/coldnew/linum-relative.git"
		"http://www.dr-qubit.org/git/undo-tree.git"
		"git://github.com/hvesalai/scala-mode2.git"
	)

	for repo in "${repos[@]}"; do
		git clone "$repo"
		echo
	done
fi

