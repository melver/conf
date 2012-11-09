#-----------------------------------------------------
# File:	    Minimalistic .bashrc
# Version:  0.1.33.7
# Author:   Marco Elver <me AT marcoelver.com>
#-----------------------------------------------------

# returns if not interactive shell
[[ $- != *i* ]] && return

. "${HOME}/.common-sh.rc"

# Options {{{

# See https://wiki.archlinux.org/index.php/Color_Bash_Prompt
txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
bakgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

TIMEFORMAT="[time]: %2R wallclock secs = ( %2U usr secs + %2S sys secs / %P%% CPU )"

shopt -s checkwinsize

# History {{{

HISTCONTROL="ignorespace"
HISTSIZE=1000
SAVEHIST=1000

shopt -s histappend

# }}}

set -o vi

# }}}

# Aliases {{{
# }}}

# Functions {{{

setprompt() {
	if [[ "$UID" == "0" ]]; then
		local pr_user_op="\[$txtrst\]#\[$txtrst\]"
		local pr_user="\[$txtred\]\u"
	else
		local pr_user_op="\[$txtrst\]\$\[$txtrst\]"
		local pr_user="\[$txtgrn\]\u"
	fi

	if [[ -n "$SSH_CLIENT" || -n "$SSH2_CLIENT" ]]; then
		local pr_host="\[$txtylw\]\h"
	else
		local pr_host="\[$txtgrn\]\h"
	fi

	PS1="\[$txtcyn\][$pr_user\[$txtcyn\]@$pr_host\[$txtcyn\]][\[$txtblu\]\w\[$txtcyn\]]$pr_user_op "
}

# }}}

setprompt
color_setup

