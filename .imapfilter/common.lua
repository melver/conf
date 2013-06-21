
-- Common functions for imapfilter configuration
-- Author: Marco Elver

contain_tocc = function(m, arg) return m:contain_to(arg) + m:contain_cc(arg) end
match_tocc   = function(m, arg) return m:match_to(arg)   + m:match_cc(arg)   end

function main_loop()
    while true do
        acc.INBOX:check_status()
        if os.getenv("IMAPFILTER_ALL") == nil then
            msgs = acc.INBOX:is_unseen()
        else
            msgs = acc.INBOX
        end

        do_filter()

        if os.getenv("IMAPFILTER_IDLE") == nil then
            break
        else
            if acc.INBOX:enter_idle() == false then
                error("Server does not support IDLE")
            end
        end
    end
end

function main()
    if os.getenv("IMAPFILTER_IDLE") == nil then
        print("Running once...")
        main_loop()
    elseif os.getenv("IMAPFILTER_IDLE") == "daemon" then
        print("Detaching (IDLE)...")
        become_daemon(10, main_loop)
    else
        print("Running (IDLE)...")
        main_loop()
    end
end

