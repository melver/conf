-- AUTOSTART

awful.util.spawn_with_shell("[ -f \"$HOME/.fehbg\" ] && /bin/sh \"$HOME/.fehbg\"")

awful.util.spawn_with_shell("[ -x '" .. awful.util.getdir("config") .. "/autostart.sh' ] && '" .. awful.util.getdir("config") .. "/autostart.sh'")

