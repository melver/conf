# .zshrc

source "${HOME}/.common-sh.rc"

# Options {{{

TIMEFMT='[time]: %E wallclock secs = ( %U usr secs + %S sys secs / %P CPU ) @ %M MB max {%J}'

# History {{{

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt HIST_NO_STORE

# Custom directory-local history, only used if file already exists
DIR_HISTFILE=.dir-histfile
DIR_HIST_FORMAT="<%s>[%s@%s][%s]$ %s"

# }}}

# }}}

# Keybindings {{{

bindkey -v
typeset -g -A key
#bindkey '\e[3~' delete-char
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
#bindkey '\e[2~' overwrite-mode
bindkey '^?' backward-delete-char
bindkey '^[[1~' beginning-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[3~' delete-char
bindkey '^[[4~' end-of-line
bindkey '^[[6~' down-line-or-history
bindkey '^[[A' up-line-or-search
bindkey '^[[D' backward-char
bindkey '^[[B' down-line-or-search
bindkey '^[[C' forward-char 
bindkey "^R" history-incremental-search-backward
# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line
# for gnome-terminal
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '!' edit-command-line

_fzf-dir-histfile() {
	zle -I
	if [[ -r "$DIR_HISTFILE" ]]; then
		local cmd="$(sed 's/^[^$]*$ //' "$DIR_HISTFILE" | uniq | fzf --tac --no-sort)"
		echo "$cmd"
		eval "$cmd" </dev/tty
		print -sr -- ${cmd%%$'\n'}
	else
		echo "$DIR_HISTFILE not found!" 1>&2
		echo
	fi
	zle redisplay
}
zle -N _fzf-dir-histfile
bindkey "^T" _fzf-dir-histfile

# }}}

# Aliases {{{

wrapped-expand-alias() {
	if zle _expand_alias; then
		if [[ "$LBUFFER" =~ "/" ]]; then
			zle backward-delete-char
		fi
	fi
}
zle -N wrapped-expand-alias
bindkey "^ " wrapped-expand-alias

# }}}

# Comp stuff {{{

zmodload zsh/complist 
autoload -Uz compinit
compinit
zstyle :compinstall filename '${HOME}/.zshrc'

#- buggy
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
#-/buggy

zstyle ':completion:*:pacman:*' force-list always
zstyle ':completion:*:*:pacman:*' menu yes select

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' menu select

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*'   force-list always

# }}}

# Window title {{{

case $TERM in
	*xterm*|rxvt*|(dt|k|E)term)
		precmd() { print -Pn "\e]0;(%L) [%n@%m]%# [%~]\a" }
		preexec_settitle() { print -Pn "\e]0;(%L) [%n@%m]%# [%~] ("; printf "%s)\a" "$1" }
	;;
	screen*)
		precmd() {
			print -n "\e]83;title \""; printf "%s\"\a" "$1"
			print -Pn "\e]0;(%L) [%n@%m]%# [%~]\a"
		}
		preexec_settitle() {
			print -n "\e]83;title \""; printf "%s\"\a" "$1"
			print -Pn "\e]0;(%L) [%n@%m]%# [%~] ("; printf "%s)\a" "$1"
		}
	;; 
esac

#}}}

# Functions {{{

setprompt() {
	# load some modules
	autoload -U colors zsh/terminfo # Used in the colour alias below
	colors
	setopt prompt_subst

	# make some aliases for the colours: (could use normal escap.seq's too)
	for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
		eval PR_$color='%{$fg[${(L)color}]%}'
	done
	PR_NO_COLOR="%{$terminfo[sgr0]%}"

	# Check the UID
	if [[ $UID -ge 1000 ]]; then # normal user
		eval PR_USER='${PR_GREEN}%n${PR_NO_COLOR}'
	elif [[ $UID -eq 0 ]]; then # root
		eval PR_USER='${PR_RED}%n${PR_NO_COLOR}'
	fi

	eval PR_USER_OP='%0(?.${PR_GREEN}.${PR_RED})%#${PR_NO_COLOR}'

	# Check if we are on SSH or not
	if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then 
		eval PR_HOST='${PR_YELLOW}%m${PR_NO_COLOR}' #SSH
	else 
		eval PR_HOST='${PR_GREEN}%m${PR_NO_COLOR}' # no SSH
	fi
	# set the prompt
	PS1_NO_USER_OP=$'${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}][${PR_BLUE}%~${PR_CYAN}]'
	PS1="${PS1_NO_USER_OP}"$'${PR_USER_OP} '
	PS2=$'%_>'
}

my_vcs_info() {
	local git_info="$(git status --porcelain -b 2>/dev/null | head -n 1 | cut -d " " -f 2)"

	if [[ -n "$git_info" ]]; then
		print -n "[${PR_YELLOW}${git_info}${PR_CYAN}]"
	fi
}

setprompt_vcs_info() {
	autoload -Uz vcs_info

	if vcs_info &>/dev/null; then
		zstyle ':vcs_info:*' enable git hg svn darcs bzr
		zstyle ':vcs_info:*' actionformats \
			'%F{5}(%f%s%F{5})%F{3}%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f'
		zstyle ':vcs_info:*' formats       \
			'%F{5}(%f%s%F{5})%F{3}%F{5}[%F{2}%b%F{5}]%f'
		zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

		_vcs_info() {
			vcs_info
			print -n "${vcs_info_msg_0_}"
		}
	else
		alias _vcs_info=my_vcs_info
	fi

	PS1="${PS1_NO_USER_OP}"$'$(_vcs_info)${PR_USER_OP} '
}

preexec() {
	if whence preexec_settitle > /dev/null; then
		preexec_settitle "$@"
	fi

	if [[ -w "$DIR_HISTFILE" && ! "$1" =~ "^ " ]]; then
		printf "$DIR_HIST_FORMAT\n" "$(date +"%Y-%m-%d %H:%M:%S %Z")" "$USER" "$HOST" "${PWD##*/}" "$1" >> "$DIR_HISTFILE"
	fi
}

setprompt
setprompt_vcs_info
color_setup

#}}}

