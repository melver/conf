#!/usr/bin/env bash
# Author: Marco Elver

set -e

: ${EDITOR:=vim}
: ${MAIL_SCRATCH:="/mnt/ramdisk/mail"}

ENABLE_SCRATCH="${MAIL_SCRATCH}/000--enable-scratch"

if [[ -d "${MAIL_SCRATCH}" ]]; then
	if [[ ! -e "${ENABLE_SCRATCH}" ]]; then
		# Upon trying to edit received/sent messages, copy to scratch space by
		# default.
		echo 1 > "${ENABLE_SCRATCH}"
	fi

	if [[ -r "${ENABLE_SCRATCH}" ]] && (( $(< "${ENABLE_SCRATCH}") )); then
		mailfile="$1"
		if [[ ! -r "$mailfile" ]]; then
			echo "Cannot read $mailfile !"
			exit 1
		fi

		if ! grep -q "^Date: " "$mailfile"; then
			# Not a received/sent message
			exec "$EDITOR" "$@"
		fi

		date="$(grep -m1 "^Date: " "$mailfile")"
		date="${date#Date: }"
		date="$(date -d "$date" "+%Y-%m-%dT%H:%M:%S")"

		from="$(grep -m1 "^From: " "$mailfile")"
		from="${from##*<}"
		from="${from%%>*}"

		subject="$(grep -m1 "^Subject: " "$mailfile" | sed 's/[^a-zA-Z0-9 -_:.@]//g')"
		subject="${subject#Subject: }"
		subject="${subject// /_}"

		cp "$mailfile" "${MAIL_SCRATCH}/${date}--${from}--${subject}.mail"

		exit 0
	fi
fi

exec "$EDITOR" "$@"
