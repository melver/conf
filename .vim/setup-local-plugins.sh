#!/usr/bin/env bash
#
# setup-local-plugins.sh: Set up local Vim plugins.
#
# Author: Marco Elver <me AT marcoelver.com>

cd "$(dirname "$0")"
BUNDLE_DIR="bundle"
INIT_BUNDLES_VIM="$(pwd)/plugin/init_bundles.vim"

setup() {
	mkdir -pv "autoload" "$BUNDLE_DIR" "plugin" "pack/${BUNDLE_DIR}"

	if vim --version | grep -qi "VIM.* 7\."; then
		# Compatibility with Vim < 8.00
		wget "https://raw.github.com/tpope/vim-pathogen/HEAD/autoload/pathogen.vim" \
			-O "autoload/pathogen.vim"
	else
		# For Vim >= 8.00
		ln -sv "../../${BUNDLE_DIR}" "pack/${BUNDLE_DIR}/start"
	fi
}

fetch_plugins() {
	echo "===== Fetching Plugins ====="
	cd "$BUNDLE_DIR"

	# Snippets
	git clone "https://github.com/SirVer/ultisnips.git" "ultisnips"
	git clone "https://github.com/honza/vim-snippets.git" "vim-snippets"

	# ALE generic syntax checking
	git clone "https://github.com/w0rp/ale.git" "ale"

	# NuSMV syntax
	git clone "https://github.com/melver/wmnusmv.vim.git" "wmnusmv"

	# Puppet syntax
	git clone "https://github.com/puppetlabs/puppet-syntax-vim.git" "puppet-syntax-vim"

	# Murphi syntax
	git clone "https://github.com/melver/murphi.vim.git" "murphi.vim"

	# Haskell
	git clone "https://github.com/neovimhaskell/haskell-vim.git" "haskell-vim"

	# Racket
	git clone "https://github.com/wlangstroth/vim-racket.git" "vim-racket"

	# Rust
	git clone "https://github.com/rust-lang/rust.vim.git" "rust.vim"

	## External via symlinks

	# OCaml
	if [[ -d "${HOME}/.opam/default/share/merlin/vim" ]]; then
		ln -sv "${HOME}/.opam/default/share/merlin/vim" "merlin"
		echo "au FileType ocaml nnoremap <buffer> <Leader>c <ESC>:MerlinErrorCheck<CR>" >> "$INIT_BUNDLES_VIM"
		echo "au FileType ocaml nnoremap <buffer> <Leader>x <ESC>:MerlinTypeOf<CR>" >> "$INIT_BUNDLES_VIM"
		echo "au FileType ocaml nnoremap <buffer> <Leader>jd <ESC>:MerlinLocate<CR>" >> "$INIT_BUNDLES_VIM"
	else
		echo "Merlin not installed!"
	fi
	if [[ -d "${HOME}/.opam/default/share/ocp-indent/vim" ]]; then
		ln -sv "${HOME}/.opam/default/share/ocp-indent/vim" "ocp-indent"
	else
		echo "ocp-indent not installed!"
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

if [[ ! -d "$BUNDLE_DIR" ]]; then
	setup
	fetch_plugins
else
	update_plugins
fi

