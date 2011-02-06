#
# .bash_profile -- executed by bash login shells
# Author: Marco Elver <marco.elver AT gmail.com>
#

[[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"

# flexible approach to user-specific paths
if [[ -f "$HOME/.mypaths" ]]; then
	export PATH="${PATH}$(grep -v '^#' "$HOME/.mypaths" |
	while read line; do
		echo -n ":$line" 
	done)"
fi
