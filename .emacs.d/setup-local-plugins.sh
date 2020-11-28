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
			( cd "$bundle" && git pull && git diff 'HEAD@{1.minutes.ago}' )
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
	git clone https://github.com/emacs-evil/evil.git

	# Undo-tree (Evil suggested)
	git clone http://www.dr-qubit.org/git/undo-tree.git

	# Company-mode
	git clone https://github.com/company-mode/company-mode.git

	# Neo Tree
	git clone https://github.com/jaypei/emacs-neotree.git

	# Scala Mode
	git clone https://github.com/ensime/emacs-scala-mode.git
fi

