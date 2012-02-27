#-----------------------------------------------------
# File:	    Minimalistic .bashrc
# Version:  0.1.33.7
# Author:   Marco Elver <marco.elver AT gmail.com>
#-----------------------------------------------------

# returns if not interactive shell
[[ $- != *i* ]] && return

. "${HOME}/.common-sh.rc"

#----------------------------
# Options
#----------------------------

HISTSIZE=1000
SAVEHIST=1000
PS1='[\u@\h]:\w\$ '
TIMEFORMAT="[time]: %2R wallclock secs = ( %2U usr secs + %2S sys secs / %P%% CPU )"

shopt -s checkwinsize

#------------------------------
# Aliases
#------------------------------

#------------------------------
# Functions
#------------------------------

color_setup

