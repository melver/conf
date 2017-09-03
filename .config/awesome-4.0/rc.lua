-- Standard awesome library
local gears = require("gears")
awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local vicious = require("vicious")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.getdir("config") .. "/theme.lua")

require("defaults")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = layouts
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   --{ "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end},
   { "lock", "xlock -mode blank" },
   { "poweroff", "system-state poweroff" },
   { "reboot", "system-state reboot" },
   { "suspend", "xlock -mode blank -startCmd 'system-state suspend'"},
   { "hibernate", "xlock -mode blank -startCmd 'system-state hibernate'"}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar

-- {{{ Colors for textboxes

local coldef  = "</span>"
local colblk  = "<span color='#1a1a1a'>"
local colred  = "<span color='#b23535'>"
local colgre  = "<span color='#60801f'>"
local colyel  = "<span color='#be6e00'>"
local colblu  = "<span color='#1f6080'>"
local colmag  = "<span color='#8f46b2'>"
local colcya  = "<span color='#73afb4'>"
local colwhi  = "<span color='#b2b2b2'>"
local colbblk = "<span color='#333333'>"
local colbred = "<span color='#ff4b4b'>"
local colbgre = "<span color='#9bcd32'>"
local colbyel = "<span color='#d79b1e'>"
local colbblu = "<span color='#329bcd'>"
local colbmag = "<span color='#cd64ff'>"
local colbcya = "<span color='#9bcdff'>"
local colbwhi = "<span color='#ffffff'>"

-- }}}

-- {{{ Top bar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))
-- }}}

-- {{{ Bottom bar

-- CPU widget
local cputwidget = wibox.widget.textbox()
vicious.register(cputwidget, vicious.widgets.cpu,
    function (widget, args)
        if  args[1] >= 50 and args[1] < 75 then
            return " | " .. colyel .. "cpu " .. coldef .. colbyel .. args[1] .. "% " .. coldef .. ""
        elseif args[1] >= 75 then
            return " | " .. colred .. "cpu " .. coldef .. colbred .. args[1] .. "% " .. coldef .. ""
        else
            return " | " .. colwhi .. "cpu " .. coldef .. colbwhi .. args[1] .. "% " .. coldef .. ""
        end
    end)

-- RAM widget
local memwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.mem)
vicious.register(memwidget, vicious.widgets.mem, " | " .. colwhi .. "mem " .. coldef .. colbwhi .. "$1% ($2 MiB) " .. coldef .. "", 12)

-- Filesystem widgets
local fswidget = wibox.widget.textbox()
vicious.register(fswidget, vicious.widgets.fs,
    function (widget, args)
        local function get_root()
            if  args["{/ used_p}"] >= 93 and args["{/ used_p}"] < 97 then
                return " | " .. colyel .. "/ " .. coldef .. colbyel .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
            elseif args["{/ used_p}"] >= 97 and args["{/ used_p}"] < 99 then
                return " | " .. colred .. "/ " .. coldef .. colbred .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
            elseif args["{/ used_p}"] >= 99 and args["{/ used_p}"] <= 100 then
                naughty.notify({ title = "Hard drive Warning", text = "No space left on root!\nMake some room.",
                                 timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
                return " | " .. colred .. "/ " .. coldef .. colbred .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
            else
                return " | " .. colwhi .. "/ " .. coldef .. colbwhi .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
            end
        end

        local function get_home()
            -- If there is no home partition, but this is also the case with NFS /home:
            if  args["{/home used_p}"] == nil then
                return ""
            else
                if args["{/home used_p}"] >= 97 and args["{/home used_p}"] < 98 then
                    return " | " .. colyel .. "/home " .. coldef .. colbyel .. args["{/home used_p}"] ..
                        "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
                elseif args["{/home used_p}"] >= 98 and args["{/home used_p}"] < 99 then
                    return " | " .. colred .. "/home " .. coldef .. colbred .. args["{/home used_p}"] ..
                        "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
                elseif args["{/home used_p}"] >= 99 and args["{/home used_p}"] <= 100 then
                    naughty.notify({ title = "Hard drive Warning", text = "No space left on /home!\nMake some room.",
                                     timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
                    return " | " .. colred .. "/home " .. coldef .. colbred .. args["{/home used_p}"] ..
                        "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
                else
                    return " | " .. colwhi .. "/home " .. coldef .. colbwhi .. args["{/home used_p}"] ..
                        "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
                end
            end
        end

        return get_root() .. get_home()
    end, 220)

-- Net widgets

-- Only create one netwidget, which will read all network interfaces anyway;
-- then in the wifi-widget, use the latest results from the netwidget to
-- display current rates (the cache should take care of this, but this allows
-- us to have one less widget which needs to be executed periodically).
local netwidget_cur_args = nil
local netwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.net)
vicious.register(netwidget, vicious.widgets.net,
    function (widget, args)
        netwidget_cur_args = args

        local function ip_addr4()
            local ip = io.popen("ip addr show eth0 2> /dev/null | grep -m 1 'inet '")
            local addr = ip:read("*a")
            ip:close()
            addr = string.match(addr, "%d+.%d+.%d+.%d+")
            return addr
        end

        local ip4 = ip_addr4()
        if ip4 == nil then
            return ""
        else
            return " | " .. colwhi .. "eth0 down " .. coldef .. colbwhi .. args["{eth0 down_kb}"] .. coldef .. " " ..
            colwhi .. "up " .. coldef .. colbwhi .. args["{eth0 up_kb}"] .. coldef .. " "
        end
    end, refresh_delay)

-- WiFi
local wifiwidget = wibox.widget.textbox()
vicious.register(wifiwidget, vicious.widgets.wifi,
    function (widget, args)
        if netwidget_cur_args == nil or args["{link}"] == 0 then
            return ""
        else
            return " | " .. colwhi .. wifi_netdev .. " " .. coldef .. colbwhi ..
                 string.format("%s [%i%%]", args["{ssid}"], math.floor(args["{link}"]/70*100)) .. coldef ..
                 colwhi .. " down " .. coldef .. colbwhi .. netwidget_cur_args["{" .. wifi_netdev .. " down_kb}"] .. coldef ..
                 colwhi .. " up "   .. coldef .. colbwhi .. netwidget_cur_args["{" .. wifi_netdev .. " up_kb}"]   .. coldef .. " "
        end
    end, refresh_delay, wifi_netdev )

-- Battery widget
local batwidget = wibox.widget.textbox()

local power_supply_battery = io.open("/sys/class/power_supply/" .. sys_battery, "r")
if power_supply_battery ~= nil then
    power_supply_battery:close()
    vicious.register(batwidget, vicious.widgets.bat,
        function (widget, args)
            if args[2] >= bat_critical*2 and args[2] < bat_critical*5 then
                return " | " .. colyel .. "bat(" .. args[1] .. ") " .. coldef .. colbyel .. args[2] .. "% " .. coldef .. ""
            elseif args[2] >= bat_critical and args[2] < bat_critical*2 then
                return " | " .. colred .. "bat(" .. args[1] .. ") " .. coldef .. colbred .. args[2] .. "% " .. coldef .. ""
            elseif args[2] < bat_critical and args[1] == "-" then
                naughty.notify({ title = "Battery Warning", text = "Battery low! "..args[2].."% left!\nBetter get some power.",
                                 timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
                return " | " .. colred .. "bat(" .. args[1] .. ") " .. coldef .. colbred .. args[2] .. "% " .. coldef .. ""
            elseif args[2] < bat_critical then
                return " | " .. colred .. "bat(" .. args[1] .. ") " .. coldef .. colbred .. args[2] .. "% " .. coldef .. ""
            else
                return " | " .. colwhi .. "bat(" .. args[1] .. ") " .. coldef .. colbwhi .. args[2] .. "% " .. coldef .. ""
            end
        end, 25, sys_battery )
else
    batwidget.text = ""
end

-- Volume widget
local volwidget = wibox.widget.textbox()
if show_volume then
    vicious.register(volwidget, vicious.widgets.volume,
            function (widget, args)
                if args[1] == 0 or args[2] == "♩" then
                    return " | " .. colwhi .. "vol " .. coldef .. colbred .. "mute" .. coldef .. ""
                else
                    return " | " .. colwhi .. "vol " .. coldef .. colbwhi .. args[1] .. "% " .. coldef .. ""
                end
            end, refresh_delay, "Master" )
        volwidget:buttons(
            awful.util.table.join(
                awful.button({ }, 1, function () awful.util.spawn("amixer -q sset Master toggle")   end),
                awful.button({ }, 3, function () awful.util.spawn( terminal .. " -e alsamixer")   end),
                awful.button({ }, 4, function () awful.util.spawn("amixer -q sset Master 2dB+") end),
                awful.button({ }, 5, function () awful.util.spawn("amixer -q sset Master 2dB-") end)
            )
        )
else
    volwidget.text = ""
end
-- }}}

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag(tags, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = top_bar_height })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }

    -- Bottom box
    s.infobox = awful.wibar({ position = "bottom", screen = s, height = bottom_bar_height })
    s.infobox:setup {
        layout = wibox.layout.align.horizontal,
        nil, -- Left widgets
        nil, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            cputwidget,
            memwidget,
            fswidget,
            wifiwidget,
            netwidget,
            batwidget,
            volwidget,
        }
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey, "Control" }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- Mouse control
    awful.key({ modkey, "Control" }, "Left",
        function ()
            mouse.coords({ -- Move mouse cursor far left
            x=mouse.coords().x - screen[mouse.screen].workarea.width,
            y=0 }) -- set y=mouse.coords().y to keep y
        end,
        {description = "...", group = "mouse"}),
    awful.key({ modkey, "Control" }, "Right",
        function ()
            mouse.coords({ -- Move mouse cursor far right
            x=mouse.coords().x + screen[mouse.screen].workarea.width,
            y=0 }) -- set y=mouse.coords().y to keep y
        end,
        {description = "...", group = "mouse"}),

    -- rough keyboard mouse control
    awful.key({ modkey, "Control" }, "w",
        function () mouse.coords({ x = mouse.coords().x, y = mouse.coords().y - 8 }) end,
        {description = "...", group = "mouse"}),
    awful.key({ modkey, "Control" }, "s",
        function () mouse.coords({ x = mouse.coords().x, y = mouse.coords().y + 8 }) end,
        {description = "...", group = "mouse"}),
    awful.key({ modkey, "Control" }, "a",
        function () mouse.coords({ x = mouse.coords().x - 8, y = mouse.coords().y }) end,
        {description = "...", group = "mouse"}),
    awful.key({ modkey, "Control" }, "d",
        function () mouse.coords({ x = mouse.coords().x + 8, y = mouse.coords().y }) end,
        {description = "...", group = "mouse"}),
    -- Need to specify each possibly combination, as it is otherwise impossible to issue e.g., Shift+MB1
    awful.key({ modkey,           }, "F6", function () awful.spawn("xdotool click --clearmodifiers 1") end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey,           }, "F7", function () awful.spawn("xdotool click --clearmodifiers 2") end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey,           }, "F8", function () awful.spawn("xdotool click --clearmodifiers 3") end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey, "Shift"   }, "F6", function () awful.spawn("xdotool click --clearmodifiers 1") end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey, "Shift"   }, "F7", function () awful.spawn("xdotool click --clearmodifiers 2") end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey, "Shift"   }, "F8", function () awful.spawn("xdotool click --clearmodifiers 3") end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey, "Control" }, "F6", function () awful.spawn("xdotool click --clearmodifiers 1") end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey, "Control" }, "F7", function () awful.spawn("xdotool click --clearmodifiers 2") end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey, "Control" }, "F8", function () awful.spawn("xdotool click --clearmodifiers 3") end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey, "Control" },  ";", function () delayed_window_focus.focus = client.focus end,
              {description = "...", group = "mouse"}),
    awful.key({ modkey,           },  ";",
        function ()
            awful.spawn.with_shell("sleep 0.5 && xdotool click --clearmodifiers 1")
            delayed_window_focus.timer:start()
        end,
        {description = "...", group = "mouse"}),

    -- Programs
    -- launchers
    awful.key({ modkey,           }, "p",      function () awful.spawn("bash -c 'exe=`dmenu-apps echo` && eval \"exec $exe\"'") end,
              {description = "open dmenu", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "p",      function () awful.spawn("gmrun") end,
              {description = "open gmrun", group = "launcher"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(terminal_alt) end,
              {description = "open a terminal (alt)", group = "launcher"}),
    -- lock screen
    awful.key({ modkey, "Control" }, "x",      function () awful.spawn("xlock-screenoff") end,
              {description = "lock and turn off screen", group = "lockscreen"}),
    awful.key({ modkey, "Shift"   }, "x",      function () awful.spawn("xlock -mode blank") end,
              {description = "just lock screen", group = "lockscreen"}),
    -- web
    awful.key({ modkey,           }, "f",      function () awful.spawn(browser) end,
              {description = "open browser", group = "web"}),
    awful.key({ modkey, "Shift"   }, "f",      function () awful.spawn(browser_private) end,
              {description = "open browser (private browsing)", group = "web"}),
    awful.key({ modkey,           }, "e",      function () awful.spawn(mail_client) end,
              {description = "open mail client", group = "web"}),
    -- system
    awful.key({ modkey, "Shift"   }, "t",      function () awful.spawn("thunar") end,
              {description = "open file browser", group = "system"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Control" }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false, -- remove space between windows
     }
    },

    -- Floating clients.
    { rule_any = {
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "Pinentry",
          "veromix",
          "xtightvncviewer",
          "Xephyr",
          "Xmessage",
          "Gxmessage",
          "Gcalctool",
          "Cssh",
          "Gimp",
          "Dia",
          "Pidgin",
          "Skype",
          "Ekiga",
          "Vlc",
          "Mplayer",
        },
        name = {
          "Event Tester",  -- xev.
          "Figure", -- Matplotlib
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {
        type = {
            --"normal",
            "dialog",
        },
        class = {
          "Xmessage",
          "Gxmessage",
          "Gcalctool",
          "Cssh",
          "Pidgin",
          "Skype",
          "Ekiga",
        },
        name = {
          "Figure" -- Matplotlib
        },
      }, properties = { titlebars_enabled = true }
    },

    -- Application mappings to tag/screen
    -- web
    { rule_any = {
        class = {
          "Chromium", "chromium", "Chrome", "Chrome",
          "Firefox", "Lanikai", "Thunderbird",
        },
        name = {
          "term-mail",
        },
      },
      properties = { tag = tags[2] },
      callback = awful.client.focus.history.add
    },
    -- doc
    { rule_any = {
        class = {
          "Epdfview",
          "Okular",
          "Zathura",
          "FBReader",
          "Evince",
        },
      },
      properties = { tag = tags[4] },
      callback = awful.client.focus.history.add
    },
    -- chat
    { rule_any = {
        class = {
          "Pidgin",
          "Skype",
          "Ekiga",
          "Xchat",
          "Mumble",
        },
      },
      properties = { tag = tags[5] },
      callback = awful.client.focus.history.add
    },
    -- gfx
    { rule_any = {
        class = {
          "Gimp",
          "Dia",
          "Inkscape",
          "Eog",
        },
      },
      properties = { tag = tags[6] },
      callback = awful.client.focus.history.add
    },
    -- media
    { rule_any = {
        class = {
          "Vlc",
          "MPlayer",
          "Sonata",
        },
      },
      properties = { tag = tags[7] },
      callback = awful.client.focus.history.add
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Autostart {{{
awful.spawn.with_shell("[ -f \"$HOME/.fehbg\" ] && /bin/sh \"$HOME/.fehbg\"")
awful.spawn.with_shell("[ -x '" .. awful.util.getdir("config") .. "/autostart.sh' ] && '" .. awful.util.getdir("config") .. "/autostart.sh'")
-- }}}
