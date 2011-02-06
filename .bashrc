# Minimalistic .bashrc

# returns if not interactive shell
[[ -z "$PS1" ]] && return

if [[ "$OSTYPE" =~ "linux" ]]; then
	alias ls='ls --color=auto'
elif [[ "$OSTYPE" =~ "freebsd" ]]; then
	alias ls='ls -G'

	alias pkg_add='sudo pkg_add'
fi

alias l='ls -F'
alias ll='ls -lh'
alias la='ls -al'

# vim without mouse, using my vimrc. set before and after reading vimrc.
alias vinom='vim --cmd "let no_mouse_please=1" --cmd "set mouse=" -c "set mouse="'
alias vimproj='vim +Project'
alias vimprojc='vim +"Project .vimprojects"'
alias gvimproj='gvim +Project'
alias gvimprojc='gvim +"Project .vimprojects"'

shopt -s checkwinsize

PS1='[\u@\h]:\w\$ '

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

