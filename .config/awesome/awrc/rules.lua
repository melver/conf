-- RULES

local function movetotag_wrap(tag, c)
    awful.client.movetotag(tag, c)

    -- If the client is moved, focus (as per properties below)
    -- is not always on the new client when switching to the tag it was moved
    -- to. The following statement fixes this.
    awful.client.focus.history.add(c)
end

awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = true,
            keys = clientkeys,
            buttons = clientbuttons,
            size_hints_honor = false -- remove space between windows
        }
    },

    -----------------------------
    -- Specific application rules
    -----------------------------
    { rule = { class = "pinentry" }, properties = { floating = true } },

    { rule = { class = "Xmessage" }, properties = { floating = true }, callback = awful.titlebar.add },

    { rule = { class = "Gxmessage" }, properties = { floating = true }, callback = awful.titlebar.add },

    { rule = { class = "Gcalctool" }, properties = { floating = true }, callback = awful.titlebar.add },

    { rule = { class = "Cssh" }, properties = { floating = true }, callback = awful.titlebar.add },

    { rule = { name = "Figure 1" }, properties = { floating = true },
        callback = awful.titlebar.add }, --Matplotlib

    { rule = { class = "Xephyr" }, properties = { floating = true } },

    -- Mapped applications
    { rule = { class = "Chromium" }, callback = function(c) movetotag_wrap(tags[mouse.screen][2], c) end },

    { rule = { class = "Firefox" }, callback = function(c) movetotag_wrap(tags[mouse.screen][2], c) end },

    { rule = { class = "Lanikai" }, callback = function(c) movetotag_wrap(tags[mouse.screen][2], c) end },

    { rule = { class = "Thunderbird" }, callback = function(c) movetotag_wrap(tags[mouse.screen][2], c) end },

    { rule = { class = "Epdfview" }, callback = function(c) movetotag_wrap(tags[mouse.screen][4], c) end },

    { rule = { class = "Evince" }, callback = function(c) movetotag_wrap(tags[mouse.screen][4], c) end },

    { rule = { class = "Okular" }, callback = function(c) movetotag_wrap(tags[mouse.screen][4], c) end },

    { rule = { class = "FBReader" }, callback = function(c) movetotag_wrap(tags[mouse.screen][4], c) end },

    { rule = { class = "Gimp" }, properties = { floating = true },
        callback = function(c) movetotag_wrap(tags[mouse.screen][6], c) end },

    { rule = { class = "Dia" }, properties = { floating = true },
        callback = function(c) movetotag_wrap(tags[mouse.screen][6], c) end },

    { rule = { class = "Inkscape" }, callback = function(c) movetotag_wrap(tags[mouse.screen][6], c) end },

    { rule = { class = "Eog" }, callback = function(c) movetotag_wrap(tags[mouse.screen][6], c) end },

    { rule = { class = "Pidgin" }, properties = { floating = true, tag = tags[1][5] },
        callback = function(c) awful.titlebar.add(c) end },

    { rule = { class = "Skype" }, properties = { floating = true, tag = tags[1][5] },
        callback = function(c) awful.titlebar.add(c) end },

    { rule = { class = "Xchat" }, properties = { tag = tags[1][5] } },

    { rule = { class = "Mumble" }, callback = function(c) movetotag_wrap(tags[1][5], c) end },

    { rule = { class = "Vlc" }, properties = { floating = true },
        callback = function(c) movetotag_wrap(tags[mouse.screen][7], c) end },

    { rule = { class = "MPlayer" }, properties = { floating = true },
        callback = function(c) movetotag_wrap(tags[mouse.screen][7], c) end },

    { rule = { class = "Clementine" }, properties = { tag = tags[1][7] } }

}

