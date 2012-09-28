#!/bin/bash
#
# compile-all.sh: Compiles all custom terminfo files
#
# Author: Marco Elver <me AT marcoelver.com>
# Date: Fri 28 Sep 10:35:12 BST 2012

screen_256color_it() {
	# See http://tmux.svn.sourceforge.net/viewvc/tmux/trunk/FAQ for more info
	local tmpfile="/tmp/screen-256color-it.terminfo"

	infocmp "screen-256color" | sed \
		-e 's/^screen[^|]*|[^,]*,/screen-256color-it|GNU Screen with 256 colors and italics support,/' \
		-e 's/%?%p1%t;3%/%?%p1%t;7%/' \
		-e 's/smso=[^,]*,/smso=\\E[7m,/' \
		-e 's/rmso=[^,]*,/rmso=\\E[27m,/' \
		-e '$s/$/ sitm=\\E[3m, ritm=\\E[23m,/' > "$tmpfile"

	tic "$tmpfile"
	rm "$tmpfile"
}

screen_256color_it

