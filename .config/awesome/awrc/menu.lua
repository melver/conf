-- MENU

devmenu = {
    { "gvim", "gvim" }
}

networkmenu = {
    { "firefox",        "firefox" },
    { "chromium",       "chromium --disk-cache-size=268435456" },
    { "thunderbird",    "thunderbird" },
    { "pidgin",         "pidgin" },
    { "skype",          "skype" },
    { "xchat",          "xchat" }
}

awesomemenu = {
    { "edit config",    editor_cmd .. " " .. awesome.conffile },
    { "restart",        awesome.restart },
    { "lock",           "xlock -mode blank" },
    { "quit",           awesome.quit },
    { "poweroff",       "shutdown-logout poweroff" },
    { "reboot",         "shutdown-logout reboot" },
    { "suspend",        "xlock -mode blank -startCmd 'system-state suspend'"},
    { "hibernate",      "xlock -mode blank -startCmd 'system-state hibernate'"}
}

mainmenu = awful.menu({
    items = {
        { "terminal",   terminal },
        { "dev",        devmenu },
        { "network",    networkmenu },
        { "awesome",    awesomemenu }
    }
})

