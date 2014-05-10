#!/usr/bin/env bash
#
# setup-local-plugins.sh: TODO: Add description here.
#
# Author: Marco Elver <me AT marcoelver.com>
# Date: Thu Apr 12 00:17:42 BST 2012

cd `dirname $0`
BUNDLE_DIR="$(pwd)/bundle"
INIT_BUNDLES_VIM="$(pwd)/plugin/init_bundles.vim"

setup_pathogen() {
	echo "===== Fetching Pathogen ====="
	mkdir -p "autoload" "$BUNDLE_DIR" "plugin"
	wget "https://raw.github.com/tpope/vim-pathogen/HEAD/autoload/pathogen.vim" \
		 -O "autoload/pathogen.vim"
}

fetch_plugins() {
	echo "===== Fetching Plugins ====="
	cd "$BUNDLE_DIR"

	# Clang complete
	git clone "https://github.com/Rip-Rip/clang_complete.git" "clang_complete"
	echo "let g:clang_complete_copen = 1" >> "$INIT_BUNDLES_VIM"

	# NuSMV syntax
	git clone "https://github.com/melver/wmnusmv.vim.git" "wmnusmv"

	# Puppet syntax
	git clone "https://github.com/puppetlabs/puppet-syntax-vim.git" "puppet-syntax-vim"

	# Murphi syntax
	git clone "https://github.com/melver/murphi.vim.git" "murphi"

	# Haskell
	git clone "https://github.com/dag/vim2hs.git" "vim2hs"

	# Erlang
	git clone "https://github.com/jimenezrick/vimerl.git" "vimerl"
}

update_plugins() {
	echo "===== Updating Plugins ====="
	cd "$BUNDLE_DIR"

	for bundle in "clang_complete" "puppet-syntax-vim" "vim2hs" "vimerl"; do
		if [[ -d "$bundle" ]]; then
			( cd "$bundle" && git pull )
		fi
	done
}

if [[ ! -f "autoload/pathogen.vim" ]]; then
	setup_pathogen
	fetch_plugins
else
	update_plugins
fi

echo "===== Done ====="

