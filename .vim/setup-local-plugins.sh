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

	# NuSMV syntax
	git clone "https://github.com/melver/wmnusmv.vim.git" "wmnusmv"

	# Puppet syntax
	git clone "https://github.com/puppetlabs/puppet-syntax-vim.git" "puppet-syntax-vim"

	# Murphi syntax
	git clone "https://github.com/melver/murphi.vim.git" "murphi.vim"

	# Syntastic generic syntax checking
	git clone "https://github.com/scrooloose/syntastic.git" "syntastic"

	# Dependency for ghcmod-vim
	git clone "https://github.com/Shougo/vimproc.vim.git" "vimproc.vim"
	(cd "vimproc.vim" && make)

	# Haskell
	git clone "https://github.com/dag/vim2hs.git" "vim2hs"
	git clone "https://github.com/eagletmt/neco-ghc.git" "neco-ghc"
	git clone "https://github.com/eagletmt/ghcmod-vim.git" "ghcmod-vim"
	echo "au FileType haskell setlocal omnifunc=necoghc#omnifunc" >> "$INIT_BUNDLES_VIM"
	echo "au FileType haskell nnoremap <buffer> <Leader>c <ESC>:w<CR>:GhcModCheckAndLintAsync<CR>" >> "$INIT_BUNDLES_VIM"
	echo "au FileType haskell nnoremap <buffer> <Leader>x <ESC>:GhcModType<CR>" >> "$INIT_BUNDLES_VIM"
	echo "au FileType haskell nnoremap <buffer> <silent> <Leader>z <ESC>:GhcModTypeClear<CR>" >> "$INIT_BUNDLES_VIM"

	# Erlang
	git clone "https://github.com/jimenezrick/vimerl.git" "vimerl"

	# Racket
	git clone "https://github.com/wlangstroth/vim-racket.git" "vim-racket"

	## External via symlinks

	# OCaml
	if [[ -d "${HOME}/.opam/system/share/merlin/vim" ]]; then
		ln -sv "${HOME}/.opam/system/share/merlin/vim" "merlin"
		echo "au FileType ocaml nnoremap <buffer> <Leader>c <ESC>:MerlinErrorCheck<CR>" >> "$INIT_BUNDLES_VIM"
		echo "au FileType ocaml nnoremap <buffer> <Leader>x <ESC>:MerlinTypeOf<CR>" >> "$INIT_BUNDLES_VIM"
	else
		echo "Merlin not installed!"
	fi

	# YouCompleteMe
	if [[ -d "${HOME}/local/YouCompleteMe" ]]; then
		ln -sv "${HOME}/local/YouCompleteMe" "YouCompleteMe"
	else
		echo "YouCompleteMe not installed!"
	fi
}

update_plugins() {
	echo "===== Updating Plugins ====="
	cd "$BUNDLE_DIR"

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

		# Special cases
		case "$bundle" in
			"vimproc.vim")
				(cd "$bundle" && make) ;;
			*) ;;
		esac

		echo
	done
}

if [[ ! -f "autoload/pathogen.vim" ]]; then
	setup_pathogen
	fetch_plugins
else
	update_plugins
fi

