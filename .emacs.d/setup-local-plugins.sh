#!/usr/bin/env bash

cd "${0%/*}"

if [[ -d "bundle" ]]; then
	echo "===== Updating Plugins ====="

	cd "bundle"

	for bundle in *; do
		if [[ -L "$bundle" ]]; then
			echo "Requires manual update: ${bundle}"
			continue
		fi

		echo "----- $bundle -----"

		if [[ -d "${bundle}/.git" ]]; then
			( cd "$bundle" && git pull )
		elif [[ -d "${bundle}/.hg" ]]; then
			( cd "$bundle" && hg pull -u )
		fi

		echo
	done

else
	echo "===== Fetching Plugins ====="

	mkdir -p "bundle" || exit 1

	cd "bundle"

	# Evil Mode
	hg clone https://bitbucket.org/lyro/evil

	# Relative line-numbering
	git clone https://github.com/coldnew/linum-relative.git

	# Undo-tree (Evil suggested)
	git clone http://www.dr-qubit.org/git/undo-tree.git

	# Scala Mode
	git clone https://github.com/ensime/emacs-scala-mode.git
fi

