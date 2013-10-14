-- WIDGETS

local vicious = require("vicious")

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

-- Textclock
local mytextclock = awful.widget.textclock()

-- Taglist
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
    )

-- Tasklist
local mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
                awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
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
        if client.focus then client.focus:raise() end
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end)
)

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

-- Ram widget
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
-- display current rates.
local netwidget_cur_args = nil

local netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
    function (widget, args)
        netwidget_cur_args = args

        local function ip_addr4()
            local ip = io.popen("ip addr show eth0 2> /dev/null | grep 'inet '")
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

-- wifi
local wifiwidget = wibox.widget.textbox()
vicious.register(wifiwidget, vicious.widgets.wifi,
    function (widget, args)
        if netwidget_cur_args == nil or args["{link}"] == 0 then
            return ""
        else
            return " | " .. colwhi .. wifi_netdev .. " " .. coldef .. colbwhi ..
                string.format("%s [%i%%]", args["{ssid}"], args["{link}"]/70*100) .. coldef ..
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

-- {{{ Create Wiboxes
local mywibox = {}
local infobox = {}
local mypromptbox = {}
local mylayoutbox = {}

-- Create for each screen
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Top box
    mywibox[s] = awful.wibox({ position = "top", height = bars_height_t, screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

    -- Bottom box
    infobox[s] = awful.wibox({ position = "bottom", height = bars_height_b, screen = s })

    local info_layout = wibox.layout.fixed.horizontal()
    info_layout:add(cputwidget)
    info_layout:add(memwidget)
    info_layout:add(fswidget)
    info_layout:add(wifiwidget)
    info_layout:add(netwidget)
    info_layout:add(batwidget)
    info_layout:add(volwidget)

    local bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_right(info_layout)

    infobox[s]:set_widget(bottom_layout)

end
-- }}}

