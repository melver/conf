
------------------------------
-- Marco's AwesomeWM config --
-- Partially based on:
-- https://github.com/JackH79/.dotfiles/blob/master/.config/awesome/rc.lua
------------------------------

-- {{{ INCLUDES
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Auxilliary libs
require("vicious")
-- }}}

-- {{{ THEME
beautiful.init(awful.util.getdir("config") .. "/themes/default.lua" )
-- }}}

-- {{{ COLOURS
coldef  = "</span>"
colblk  = "<span color='#1a1a1a'>"
colred  = "<span color='#b23535'>"
colgre  = "<span color='#60801f'>"
colyel  = "<span color='#be6e00'>"
colblu  = "<span color='#1f6080'>"
colmag  = "<span color='#8f46b2'>"
colcya  = "<span color='#73afb4'>"
colwhi  = "<span color='#b2b2b2'>"
colbblk = "<span color='#333333'>"
colbred = "<span color='#ff4b4b'>"
colbgre = "<span color='#9bcd32'>"
colbyel = "<span color='#d79b1e'>"
colbblu = "<span color='#329bcd'>"
colbmag = "<span color='#cd64ff'>"
colbcya = "<span color='#9bcdff'>"
colbwhi = "<span color='#ffffff'>"
-- }}}

-- {{{ DEFAULTS
terminal = "roxterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser = "chromium"
modkey = "Mod4"

-- layouts
layouts = {
	awful.layout.suit.max,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.floating,
}
-- }}}

-- {{{ TAGS
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(
				{ 
					1,
					2,
					"3:web",
					4,
					5,
					6,
					7,
					8,
					9
				},
				s, layouts[1])
end
-- }}}

-- {{{ MENU
networkmenu = {
	{ "firefox",    "firefox" },
	{ "chromium", 	"chromium --disk-cache-size=52428800" },
	{ "thunderbird", "thunderbird" },
	{ "xchat",       "xchat" },
}

awesomemenu = {
	{ "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	{ "restart",     awesome.restart },
	{ "lock",        "xlock -mode blank" },
	{ "quit",        awesome.quit },
	{ "reboot",      terminal .. " -e reboot" },
	{ "shutdown",    terminal .. " -e shutdown" }
}

mainmenu = awful.menu({
	items = {
		{ "network",   networkmenu },
		{ "awesome",   awesomemenu }
	}
})

-- }}}

-- {{{ WIDGETS
-- CPU widget
cputwidget = widget({ type = "textbox" })
	vicious.register(cputwidget, vicious.widgets.cpu,
	function (widget, args)
		if  args[1] == 50 then
			return "" .. colyel .. "cpu " .. coldef .. colbyel .. args[1] .. "% " .. coldef .. ""
		elseif args[1] >= 50 then
			return "" .. colred .. "cpu " .. coldef .. colbred .. args[1] .. "% " .. coldef .. ""
		else
			return "" .. colblk .. "cpu " .. coldef .. colbblk .. args[1] .. "% " .. coldef .. ""
		end
	end )
cputwidget:buttons(awful.util.table.join(awful.button({}, 1, function () awful.util.spawn ( terminal .. " -e htop --sort-key PERCENT_CPU") end ) ) )

-- CPU temp widget
tempwidget = widget({ type = "textbox" })
	vicious.register(tempwidget, vicious.widgets.thermal,
	function (widget, args)
		if  args[1] >= 65 and args[1] < 75 then
			return "" .. colyel .. "temp " .. coldef .. colbyel .. args[1] .. "°C " .. coldef .. ""
		elseif args[1] >= 75 and args[1] < 80 then
			return "" .. colred .. "temp " .. coldef .. colbred .. args[1] .. "°C " .. coldef .. ""
		elseif args[1] > 80 then
			naughty.notify({ title = "Temperature Warning", text = "Running hot! " .. args[1] .. "°C!\nTake it easy.", timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
			return "" .. colred .. "temp " .. coldef .. colbred .. args[1] .. "°C " .. coldef .. "" 
		else
			return "" .. colblk .. "temp " .. coldef .. colbblk .. args[1] .. "°C " .. coldef .. ""
		end
	end, 19, "thermal_zone0" )

-- Ram widget
memwidget = widget({ type = "textbox" })
	vicious.cache(vicious.widgets.mem)
	vicious.register(memwidget, vicious.widgets.mem, "" .. colblk .. "ram " .. coldef .. colbblk .. "$1% ($2 MiB) " .. coldef .. "", 13)

-- Filesystem widgets
-- root
fsrwidget = widget({ type = "textbox" })
	vicious.register(fsrwidget, vicious.widgets.fs,
	function (widget, args)
		if  args["{/ used_p}"] >= 93 and args["{/ used_p}"] < 97 then
			return "" .. colyel .. "/ " .. coldef .. colbyel .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
		elseif args["{/ used_p}"] >= 97 and args["{/ used_p}"] < 99 then
			return "" .. colred .. "/ " .. coldef .. colbred .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
		elseif args["{/ used_p}"] >= 99 and args["{/ used_p}"] <= 100 then
			naughty.notify({ title = "Hard drive Warning", text = "No space left on root!\nMake some room.", timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
			return "" .. colred .. "/ " .. coldef .. colbred .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. "" 
		else
			return "" .. colblk .. "/ " .. coldef .. colbblk .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
		end
	end, 620)
-- /home
fshwidget = widget({ type = "textbox" })
	vicious.register(fshwidget, vicious.widgets.fs,
	function (widget, args)
		if  args["{/home used_p}"] >= 97 and args["{/home used_p}"] < 98 then
			return "" .. colyel .. "/home " .. coldef .. colbyel .. args["{/home used_p}"] .. "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
		elseif args["{/home used_p}"] >= 98 and args["{/home used_p}"] < 99 then
			return "" .. colred .. "/home " .. coldef .. colbred .. args["{/home used_p}"] .. "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
		elseif args["{/home used_p}"] >= 99 and args["{/home used_p}"] <= 100 then
			naughty.notify({ title = "Hard drive Warning", text = "No space left on /home!\nMake some room.", timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
			return "" .. colred .. "/home " .. coldef .. colbred .. args["{/home used_p}"] .. "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. "" 
		else
			return "" .. colblk .. "/home " .. coldef .. colbblk .. args["{/home used_p}"] .. "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
		end
	end, 620)

-- Net widgets
-- eth
neteupwidget = widget({ type = "textbox" })
	vicious.cache(vicious.widgets.net)
	vicious.register(neteupwidget, vicious.widgets.net, "" .. colblk .. "up " .. coldef .. colbblk .. "${eth0 up_kb} " .. coldef .. "")

netedownwidget = widget({ type = "textbox" })
	vicious.register(netedownwidget, vicious.widgets.net, "" .. colblk .. "down " ..coldef .. colbblk .. "${eth0 down_kb} " .. coldef .. "")

netwidget = widget({ type = "textbox" })
	vicious.register(netwidget, vicious.widgets.netinfo,
	function (widget, args)
		if args["{ip}"] == nil then
			netedownwidget.visible = false
			neteupwidget.visible = false
			return ""
		else
			netedownwidget.visible = true
			neteupwidget.visible = true
			return "" .. colblk .. "eth0 " .. coldef .. colbblk .. args["{ip}"] .. coldef .. " "
		end
	end, refresh_delay, "eth0")

-- wlan
netwupwidget = widget({ type = "textbox" })
	vicious.register(netwupwidget, vicious.widgets.net, "" .. colblk .. "up " .. coldef .. colbblk .. "${wlan0 up_kb} " .. coldef .. "")

netwdownwidget = widget({ type = "textbox" })
	vicious.register(netwdownwidget, vicious.widgets.net, "" .. colblk .. "down " .. coldef .. colbblk .. "${wlan0 down_kb} " .. coldef .. "")

wifiwidget = widget({ type = "textbox" })
	vicious.register(wifiwidget, vicious.widgets.wifi,
	function (widget, args)
		if args["{link}"] == 0 then
			netwdownwidget.visible = false
			netwupwidget.visible = false
			return ""
		else
			netwdownwidget.visible = true
			netwupwidget.visible = true
			return "" .. colblk .. "wlan " .. coldef .. colbblk .. string.format("%s [%i%%]", args["{ssid}"], args["{link}"]/70*100) .. coldef .. " "
		end
	end, refresh_delay, "wlan0" )

-- Battery widget
batwidget = widget({ type = "textbox" })
	vicious.register(batwidget, vicious.widgets.bat,
	function (widget, args)
		if args[2] >= 50 and args[2] < 75 then
			return "" .. colyel .. "bat " .. coldef .. colbyel .. args[2] .. "% " .. coldef .. ""
		elseif args[2] >= 20 and args[2] < 50 then
			return "" .. colred .. "bat " .. coldef .. colbred .. args[2] .. "% " .. coldef .. ""
		elseif args[2] < 20 and args[1] == "-" then
			naughty.notify({ title = "Battery Warning", text = "Battery low! "..args[2].."% left!\nBetter get some power.", timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
			return "" .. colred .. "bat " .. coldef .. colbred .. args[2] .. "% " .. coldef .. ""
		elseif args[2] < 20 then 
			return "" .. colred .. "bat " .. coldef .. colbred .. args[2] .. "% " .. coldef .. ""
		else
			return "" .. colblk .. "bat " .. coldef .. colbblk .. args[2] .. "% " .. coldef .. ""
		end
	end, 23, "BAT0"	)

-- Volume widget
volwidget = widget({ type = "textbox" })
	vicious.register(volwidget, vicious.widgets.volume,
		function (widget, args)
			if args[1] == 0 or args[2] == "♩" then
				return "" .. colblk .. "vol " .. coldef .. colbred .. "mute" .. coldef .. "" 
			else
				return "" .. colblk .. "vol " .. coldef .. colbblk .. args[1] .. "% " .. coldef .. ""
			end
		end, 2, "Master" )
	volwidget:buttons(
		awful.util.table.join(
			awful.button({ }, 1, function () awful.util.spawn("amixer -q sset Master toggle")   end),
			awful.button({ }, 3, function () awful.util.spawn( terminal .. " -e alsamixer")   end),
			awful.button({ }, 4, function () awful.util.spawn("amixer -q sset Master 2dB+") end),
			awful.button({ }, 5, function () awful.util.spawn("amixer -q sset Master 2dB-") end)
		)
	)
-- }}}

-- {{{ SYSTRAY
mytextclock = awful.widget.textclock({ align = "right" })
mysystray = widget({ type = "systray" })
-- }}}

-- {{{ WIBOXES
mywibox = {}
infobox = {}
mypromptbox = {}
mylayoutbox = {}
-- taglist
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ modkey }, 1, awful.client.movetotag),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, awful.client.toggletag),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
	)
-- tasklist
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if not c:isvisible() then
			awful.tag.viewonly(c:tags()[1])
		end
		client.focus = c
		c:raise()
	end),
	awful.button({ }, 3, function ()
		if instance then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ width=250 })
		end
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
		if client.focus then
			client.focus:raise()
		end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
		if client.focus then
			client.focus:raise()
		end
	end)
)
-- Create for each screen
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

	-- top box
	mywibox[s] = awful.wibox({ position = "top", height = "14", screen = s })
	mywibox[s].widgets = {
		{
			mytaglist[s],
			mypromptbox[s],
			layout = awful.widget.layout.horizontal.leftright 
		},
		mylayoutbox[s],
		mytextclock,
		s == 1 and mysystray or nil,
		mytasklist[s],
		layout = awful.widget.layout.horizontal.rightleft }
	-- bottom box
	infobox[s] = awful.wibox({ position = "bottom", height = "14", screen = s })
	infobox[s].widgets = { {
		mpdwidget, layout = awful.widget.layout.horizontal.leftright },
		volwidget,
		batwidget,
		neteupwidget, netedownwidget, netwidget,
		netwupwidget, netwdownwidget, wifiwidget,
		fshwidget, fsrwidget,
		memwidget,
		tempwidget,
		cputwidget,
		layout = awful.widget.layout.horizontal.rightleft }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function () mainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev))
)
-- }}}

-- {{{ Key bindings
-- Global
globalkeys = awful.util.table.join(
	-- Tags
	awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

	-- Awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

	-- Programs
	-- launchers
	awful.key({ modkey,           }, "w",                     function () mainmenu:show({keygrabber=true}) end),
	awful.key({ modkey,           }, "p",                     function () awful.util.spawn("bash -c 'exe=`dmenu-apps echo` && eval \"exec $exe\"'") end),
	awful.key({ modkey, "Shift"   }, "p",                     function () awful.util.spawn("gmrun") end),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal) end),
	-- miscellaneous
	awful.key({ modkey, "Shift"   }, "l",                     function () awful.util.spawn("xlock-screenoff") end),
	-- web
	awful.key({ modkey,           }, "f",                     function () awful.util.spawn(browser) end),
	awful.key({ modkey,           }, "e",                     function () awful.util.spawn("thunderbird") end),
	-- file managers
	awful.key({ modkey,           }, "t",                     function () awful.util.spawn("thunar") end)
)

-- Clients
clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "o",                    function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"   }, "c",                    function (c) c:kill() end),
	awful.key({ modkey, "Control" }, "space",                awful.client.floating.toggle ),
	awful.key({ modkey, "Control" }, "Return",               function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey, "Control" }, "o",                    awful.client.movetoscreen ),
	awful.key({ modkey,           }, "n",                    function (c) c.minimized = not c.minimized end),
	awful.key({ modkey, "Shift"   }, "n",                    function ()
		local allclients = client.get(mouse.screen)
		for _,c in ipairs(allclients) do
			if c.minimized and c:tags()[mouse.screen] == awful.tag.selected(mouse.screen) then
				c.minimized = false client.focus = c c:raise()
				return end end end), awful.key({ modkey,
			}, "f",                    function (c)
				c.maximized_horizontal = not
				c.maximized_horizontal c.maximized_vertical   =
				not c.maximized_vertical end))

-- Compute maximum number of digit we need
keynumber = 0
for s = 1, screen.count() do
	keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
	globalkeys = awful.util.table.join(globalkeys,
	awful.key({ modkey }, "#" .. i + 9,
	function ()
		local screen = mouse.screen
		if tags[screen][i] then
			awful.tag.viewonly(tags[screen][i])
		end
	end),
	awful.key({ modkey, "Control" }, "#" .. i + 9,
	function ()
		local screen = mouse.screen
		if tags[screen][i] then
			awful.tag.viewtoggle(tags[screen][i])
		end
	end),
	awful.key({ modkey, "Shift" }, "#" .. i + 9,
	function ()
		if client.focus and tags[client.focus.screen][i] then
			awful.client.movetotag(tags[client.focus.screen][i])
		end
	end),
	awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
	function ()
		if client.focus and tags[client.focus.screen][i] then
			awful.client.toggletag(tags[client.focus.screen][i])
		end
	end))
end

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ RULES
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
	{ rule = { class = "MPlayer" }, properties = { floating = true } },
	{ rule = { class = "pinentry" }, properties = { floating = true } },
	{ rule = { class = "gimp" }, properties = { floating = true } },
	{ rule = { class = "Xmessage" }, properties = { floating = true } },
	{ rule = { class = "Gxmessage" }, properties = { floating = true } },
	{ rule = { class = "Vlc" }, properties = { floating = true } },
	{ rule = { class = "Pidgin" }, properties = { floating = true } },
	{ rule = { class = "Skype" }, properties = { floating = true } },

	-- Mapping rules
	{ rule = { class = "Chromium" }, properties = { tag = tags[1][3] } },
	{ rule = { class = "Lanikai" }, properties = { tag = tags[1][3] } },
}
-- }}}

-- {{{ SIGNALS
client.add_signal("manage", function (c, startup)
	-- Add a titlebar
	-- awful.titlebar.add(c, { modkey = modkey })

	-- Enable sloppy focus
	c:add_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
			and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

	if not startup then
		-- Set the windows at the slave,
		-- i.e. put it at the end of others instead of setting it master.
		-- awful.client.setslave(c)

		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ vim modline
--  vim: set ts=4 sw=4 sts=4 noet foldmarker={{{,}}} foldlevel=0 fen fdm=marker:
-- }}}
