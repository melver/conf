
dofile(os.getenv("HOME") .. "/.imapfilter/common.lua")

---------------
--  Options  --
---------------

options.timeout = 120
-- options.subscribe = true

-- Uncomment the following option if imapfilter does not appear to receive
-- updates via IDLE after a longer period of inactivity. This value is 29 by
-- default (recommended by IMAP RFC), meaning after 29 minutes imapfilter
-- reissues the IDLE command, but for some servers this appears to be too long.
--options.keepalive = 20

----------------
--  Accounts  --
----------------

pw_proc = io.popen("~/.mutt/bin/gpg_mutt_secrets.py my_pw_nameexamplecom")
acc = IMAP {
    server = 'imap.example.com',
    username = 'name@example.com',
    password = pw_proc:read("*a"):sub(1,-2),
    ssl = 'ssl3',
}
pw_proc:close()

get_INBOX = function() return acc.INBOX end

----------------
--  Filters   --
----------------

-- Individual filters
function do_filter()
    results = match_tocc(msgs, '(list1|list2)@example.com')
    results:move_messages(acc['example.com/Lists'])

    results = msgs:contain_from('boss@example.com')
    results:move_messages(acc['example.com/Urgent'])
end

main()

