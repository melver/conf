#-------------------------------------------------------------------------#
# File:     .zshrc   ZSH resource file                                    #
# Version:  0.1.33.7                                                      #
# Author: Marco Elver <marco.elver AT gmail.com>                          #
# Original Author: Øyvind "Mr.Elendig" Heggstad <mrelendig@har-ikkje.net> #
#-------------------------------------------------------------------------#

source "${HOME}/.common-sh.rc"

# Options {{{

TIMEFMT='%J  %U user %S system %P cpu %E total'

# History {{{

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt HIST_NO_STORE

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

# }}}

# Aliases {{{
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

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*'   force-list always

# }}}

# Window title {{{

case $TERM in
	*xterm*|rxvt*|(dt|k|E)term)
		precmd () { print -Pn "\e]0;(%L) [%n@%M]%# [%~]\a" } 
		preexec () { print -Pn "\e]0;(%L) [%n@%M]%# [%~] ($1)\a" }
	;;
	screen*)
		precmd () { 
			print -Pn "\e]83;title \"$1\"\a" 
			print -Pn "\e]0;(%L) [%n@%M]%# [%~]\a" 
		}
		preexec () { 
			print -Pn "\e]83;title \"$1\"\a" 
			print -Pn "\e]0;(%L) [%n@%M]%# [%~] ($1)\a" 
		}
	;; 
esac

#}}}

# Functions {{{

setprompt () {
	# load some modules
	autoload -U colors zsh/terminfo # Used in the colour alias below
	colors
	setopt prompt_subst

	# make some aliases for the colours: (coud use normal escap.seq's too)
	for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
		eval PR_$color='%{$fg[${(L)color}]%}'
	done
	PR_NO_COLOR="%{$terminfo[sgr0]%}"

	# Check the UID
	if [[ $UID -ge 1000 ]]; then # normal user
		eval PR_USER='${PR_GREEN}%n${PR_NO_COLOR}'
		eval PR_USER_OP='${PR_GREEN}%#${PR_NO_COLOR}'
	elif [[ $UID -eq 0 ]]; then # root
		eval PR_USER='${PR_RED}%n${PR_NO_COLOR}'
		eval PR_USER_OP='${PR_RED}%#${PR_NO_COLOR}'
	fi	

	# Check if we are on SSH or not
	if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then 
		eval PR_HOST='${PR_YELLOW}%M${PR_NO_COLOR}' #SSH
	else 
		eval PR_HOST='${PR_GREEN}%M${PR_NO_COLOR}' # no SSH
	fi
	# set the prompt
	PS1=$'${PR_CYAN}[${PR_USER}${PR_CYAN}@${PR_HOST}${PR_CYAN}][${PR_BLUE}%~${PR_CYAN}]${PR_USER_OP} '
	PS2=$'%_>'
}

setprompt
color_setup

#}}}

