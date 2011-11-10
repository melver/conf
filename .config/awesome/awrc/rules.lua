-- RULES

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

	-- Specific application rules
	{ rule = { class = "pinentry" }, properties = { floating = true } },
	{ rule = { class = "Xmessage" }, properties = { floating = true }, callback = awful.titlebar.add },
	{ rule = { class = "Gxmessage" }, properties = { floating = true }, callback = awful.titlebar.add },
	{ rule = { class = "Gcalctool" }, properties = { floating = true }, callback = awful.titlebar.add },
	{ rule = { class = "Cssh" }, properties = { floating = true }, callback = awful.titlebar.add },
	{ rule = { name = "Figure 1" }, properties = { floating = true }, callback = awful.titlebar.add },--Matplotlib
	{ rule = { class = "Xephyr" }, properties = { floating = true } },

	-- Mapped applications
	{ rule = { class = "Chromium" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][2], c) end },
	{ rule = { class = "Firefox" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][2], c) end },
	{ rule = { class = "Lanikai" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][2], c) end },
	{ rule = { class = "Thunderbird" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][2], c) end },
	{ rule = { class = "Epdfview" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][4], c) end },
	{ rule = { class = "Evince" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][4], c) end },
	{ rule = { class = "Okular" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][4], c) end },
	{ rule = { class = "FBReader" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][4], c) end },
	{ rule = { class = "Gimp" }, properties = { floating = true }, callback = function(c) awful.client.movetotag(tags[mouse.screen][6], c) end },
	{ rule = { class = "Dia" }, properties = { floating = true }, callback = function(c) awful.client.movetotag(tags[mouse.screen][6], c) end },
	{ rule = { class = "Inkscape" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][6], c) end },
	{ rule = { class = "Eog" }, callback = function(c) awful.client.movetotag(tags[mouse.screen][6], c) end },
	{ rule = { class = "Pidgin" }, properties = { floating = true, tag = tags[1][5] }, callback = awful.titlebar.add },
	{ rule = { class = "Skype" }, properties = { floating = true, tag = tags[1][5] }, callback = awful.titlebar.add },
	{ rule = { class = "Xchat" }, properties = { tag = tags[1][5] } },
	{ rule = { class = "Mumble" }, properties = { tag = tags[1][5] } },
	{ rule = { class = "Vlc" }, properties = { floating = true }, callback = function(c) awful.client.movetotag(tags[mouse.screen][7], c) end },
	{ rule = { class = "MPlayer" }, properties = { floating = true }, callback = function(c) awful.client.movetotag(tags[mouse.screen][7], c) end },
	{ rule = { class = "Clementine" }, properties = { tag = tags[1][7] } }

}

