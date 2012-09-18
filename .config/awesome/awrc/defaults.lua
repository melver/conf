-- DEFAULTS

-- Variable definitions

terminal     = "urxvt"
terminal_alt = "urxvt -e zsh"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser = "chromium --disk-cache-size=268435456"
browser_private = "chromium --incognito --disk-cache-size=268435456"
modkey = "Mod4"

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

