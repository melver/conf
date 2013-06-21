
dofile(os.getenv("HOME") .. "/.imapfilter/common.lua")

---------------
--  Options  --
---------------

options.timeout = 120
-- options.subscribe = true

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

