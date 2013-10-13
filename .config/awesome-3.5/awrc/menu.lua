-- MENU

local devmenu = {
    { "gvim", "gvim" }
}

local networkmenu = {
    { "firefox",        "firefox" },
    { "chromium",       "chromium --disk-cache-size=268435456" },
    { "thunderbird",    "thunderbird" },
    { "pidgin",         "pidgin" },
    { "skype",          "skype" },
    { "xchat",          "xchat" }
}

local awesomemenu = {
    { "edit config",    editor_cmd .. " " .. awesome.conffile },
    { "restart",        awesome.restart },
    { "lock",           "xlock -mode blank" },
    { "quit",           awesome.quit },
    { "poweroff",       "system-state poweroff" },
    { "reboot",         "system-state reboot" },
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

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

