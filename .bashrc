#-----------------------------------------------------
# File:	    Minimalistic .bashrc
# Version:  0.1.33.7
# Author:   Marco Elver <marco.elver AT gmail.com>
#-----------------------------------------------------

# returns if not interactive shell
[[ $- != *i* ]] && return

#----------------------------
# Aliases
#----------------------------

if [[ "$OSTYPE" =~ "linux" ]]; then
	alias ls='ls --color=auto'
elif [[ "$OSTYPE" =~ "freebsd" ]]; then
	alias ls='ls -G'
fi

alias l='ls -F'
alias ll='ls -lh'
alias la='ls -al'

alias vinom='vim --cmd "let no_mouse_please=1" --cmd "set mouse=" -c "set mouse="'
alias vimproj='vim +Project'
alias vimprojc='vim +"Project .vimprojects"'
alias vimprojv='vim +"Project vimprojects"'
alias gvimproj='gvim +Project'
alias gvimprojc='gvim +"Project .vimprojects"'
alias gvimprojv='gvim +"Project vimprojects"'
alias gvimaf='gvim --cmd "let use_alt_font=1"'
alias vimnoac='vim +"let g:clang_complete_auto=0"'
alias gvimnoac='gvim +"let g:clang_complete_auto=0"'

#----------------------------
# Options
#----------------------------

shopt -s checkwinsize

PS1='[\u@\h]:\w\$ '
TIMEFORMAT="[time]: %2R wallclock secs = ( %2U usr secs + %2S sys secs / %P%% CPU )"

#----------------------------
# Functions
#----------------------------

xtract () {
  if [[ -f $1 ]] ; then
    case $1 in
      *.tar.bz2)   tar xvvjf $1   ;;
      *.tar.gz)    tar xvvzf $1   ;;
      *.tar.lzma)  tar --lzma -xvvf $1 ;;
      *.tar.xz)    tar xvvJf $1   ;;
      *.tar)       tar xvvf $1    ;;
      *.tbz2)      tar xvvjf $1   ;;
      *.tgz)       tar xvvzf $1   ;;
      *.txz)       tar xvvJf $1   ;;
      *.bz2)       bunzip2 $1    ;;
      *.rar)       unrar x $1    ;;
      *.gz)        gunzip $1     ;;
      *.zip)       unzip $1      ;;
      *.Z)         uncompress $1 ;;
      *.7z)        7z x $1       ;;
      *)           echo "'$1' cannot be extracted (format unknown) !" ;;
    esac
  else
    echo "'$1' is not a valid file !"
  fi
}

gin () {
	cat >> $HOME/gtd-inbox <<EOF
[$(date "+%a %d/%m/%Y %H:%M %Z") @ $(hostname)] $*
EOF
}

