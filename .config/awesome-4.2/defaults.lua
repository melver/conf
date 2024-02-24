local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Variable definitions

-- Programs
terminal     = "term"
terminal_alt = "term -e zsh"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser = "chromium --disk-cache-size=268435456"
browser_private = "chromium --incognito --disk-cache-size=268435456"
mail_client = "term-mail " .. terminal
modkey = "Mod4"

-- Monitoring
wifi_netdev = "wlan0"
sys_battery = "BAT0"
bat_critical = 10
show_volume = true
refresh_delay = 3

top_bar_height = dpi(11)
bottom_bar_height = dpi(10)

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
    awful.layout.suit.max,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
    awful.layout.suit.max.fullscreen,
}

tags = { "1:term", "2:web", "3:work", "4:doc", "5:chat", "6:gfx", "7:media", "8", "9" }

