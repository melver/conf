-- WIDGETS

-- {{{ Top bar

-- Systray
mysystray = widget({ type = "systray" })

-- Textclock
mytextclock = awful.widget.textclock({ align = "right" })

-- Taglist
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
    )

-- Tasklist
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
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
cputwidget = widget({ type = "textbox" })
vicious.register(cputwidget, vicious.widgets.cpu,
    function (widget, args)
        if  args[1] >= 50 and args[1] < 75 then
            return " | " .. colyel .. "cpu " .. coldef .. colbyel .. args[1] .. "% " .. coldef .. ""
        elseif args[1] >= 75 then
            return " | " .. colred .. "cpu " .. coldef .. colbred .. args[1] .. "% " .. coldef .. ""
        else
            return " | " .. colwhi .. "cpu " .. coldef .. colbwhi .. args[1] .. "% " .. coldef .. ""
        end
    end )

-- Ram widget
memwidget = widget({ type = "textbox" })
vicious.cache(vicious.widgets.mem)
vicious.register(memwidget, vicious.widgets.mem, " | " .. colwhi .. "mem " .. coldef .. colbwhi .. "$1% ($2 MiB) " .. coldef .. "", 13)

-- Filesystem widgets
-- root
fsrwidget = widget({ type = "textbox" })
vicious.register(fsrwidget, vicious.widgets.fs,
    function (widget, args)
        if  args["{/ used_p}"] >= 93 and args["{/ used_p}"] < 97 then
            return " | " .. colyel .. "/ " .. coldef .. colbyel .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
        elseif args["{/ used_p}"] >= 97 and args["{/ used_p}"] < 99 then
            return " | " .. colred .. "/ " .. coldef .. colbred .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
        elseif args["{/ used_p}"] >= 99 and args["{/ used_p}"] <= 100 then
            naughty.notify({ title = "Hard drive Warning", text = "No space left on root!\nMake some room.", timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
            return " | " .. colred .. "/ " .. coldef .. colbred .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. "" 
        else
            return " | " .. colwhi .. "/ " .. coldef .. colbwhi .. args["{/ used_p}"] .. "% (" .. args["{/ avail_gb}"] .. " GiB free) " .. coldef .. ""
        end
    end, 620)

-- /home
fshwidget = widget({ type = "textbox" })
vicious.register(fshwidget, vicious.widgets.fs,
    function (widget, args)
        -- If there is no home partition, but this is also the case with NFS /home:
        if  args["{/home used_p}"] == nil then
            return ""
        end

        if  args["{/home used_p}"] >= 97 and args["{/home used_p}"] < 98 then
            return " | " .. colyel .. "/home " .. coldef .. colbyel .. args["{/home used_p}"] .. "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
        elseif args["{/home used_p}"] >= 98 and args["{/home used_p}"] < 99 then
            return " | " .. colred .. "/home " .. coldef .. colbred .. args["{/home used_p}"] .. "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
        elseif args["{/home used_p}"] >= 99 and args["{/home used_p}"] <= 100 then
            naughty.notify({ title = "Hard drive Warning", text = "No space left on /home!\nMake some room.", timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
            return " | " .. colred .. "/home " .. coldef .. colbred .. args["{/home used_p}"] .. "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. "" 
        else
            return " | " .. colwhi .. "/home " .. coldef .. colbwhi .. args["{/home used_p}"] .. "% (" .. args["{/home avail_gb}"] .. " GiB free) " .. coldef .. ""
        end
    end, 620)

-- Net widgets
-- eth
neteupwidget = widget({ type = "textbox" })
vicious.cache(vicious.widgets.net)
vicious.register(neteupwidget, vicious.widgets.net, "" .. colwhi .. "up " .. coldef .. colbwhi .. "${eth0 up_kb} " .. coldef .. "")

netedownwidget = widget({ type = "textbox" })
vicious.register(netedownwidget, vicious.widgets.net, "" .. colwhi .. "down " ..coldef .. colbwhi .. "${eth0 down_kb} " .. coldef .. "")

netwidget = widget({ type = "textbox" })
vicious.register(netwidget, vicious.widgets.net,
    function (widget, args)
            function ip_addr4()
                local ip = io.popen("ip addr show eth0 2> /dev/null | grep 'inet '")
                local addr = ip:read("*a")
                ip:close()
                addr = string.match(addr, "%d+.%d+.%d+.%d+")
                return addr
            end

        local ip4 = ip_addr4()
        if ip4 == nil then
            netedownwidget.visible = false
            neteupwidget.visible = false
            return ""
        else
            netedownwidget.visible = true
            neteupwidget.visible = true
            return " | " .. colwhi .. "eth0 " .. coldef --.. colbwhi .. ip4 .. coldef .. " "
        end
    end, refresh_delay, "eth0")

-- wifi_netdev
netwupwidget = widget({ type = "textbox" })
vicious.register(netwupwidget, vicious.widgets.net, "" .. colwhi .. "up " .. coldef .. colbwhi .. "${" .. wifi_netdev .. " up_kb} " .. coldef .. "")

netwdownwidget = widget({ type = "textbox" })
vicious.register(netwdownwidget, vicious.widgets.net, "" .. colwhi .. "down " .. coldef .. colbwhi .. "${" .. wifi_netdev .. " down_kb} " .. coldef .. "")

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
            return " | " .. colwhi .. wifi_netdev .. " " .. coldef .. colbwhi .. string.format("%s [%i%%]", args["{ssid}"], args["{link}"]/70*100) .. coldef .. " "
        end
    end, refresh_delay, wifi_netdev )

-- Battery widget
batwidget = widget({ type = "textbox" })

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
                naughty.notify({ title = "Battery Warning", text = "Battery low! "..args[2].."% left!\nBetter get some power.", timeout = 10, position = "top_right", fg = beautiful.fg_urgent, bg = beautiful.bg_urgent })
                return " | " .. colred .. "bat(" .. args[1] .. ") " .. coldef .. colbred .. args[2] .. "% " .. coldef .. ""
            elseif args[2] < bat_critical then
                return " | " .. colred .. "bat(" .. args[1] .. ") " .. coldef .. colbred .. args[2] .. "% " .. coldef .. ""
            else
                return " | " .. colwhi .. "bat(" .. args[1] .. ") " .. coldef .. colbwhi .. args[2] .. "% " .. coldef .. ""
            end
        end, 23, sys_battery )
else
    batwidget.text = ""
end

-- Volume widget
volwidget = widget({ type = "textbox" })
if show_volume then
    vicious.register(volwidget, vicious.widgets.volume,
            function (widget, args)
                if args[1] == 0 or args[2] == "♩" then
                    return " | " .. colwhi .. "vol " .. coldef .. colbred .. "mute" .. coldef .. "" 
                else
                    return " | " .. colwhi .. "vol " .. coldef .. colbwhi .. args[1] .. "% " .. coldef .. ""
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
else
    volwidget.text = ""
end
-- }}}

-- {{{ Create Wiboxes
mywibox = {}
infobox = {}
mypromptbox = {}
mylayoutbox = {}

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

    -- Top box
    mywibox[s] = awful.wibox({ position = "top", height = bars_height, screen = s })
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

    -- Bottom box
    infobox[s] = awful.wibox({ position = "bottom", height = bars_height, screen = s })
    infobox[s].widgets = { 
        volwidget,
        batwidget,
        neteupwidget, netedownwidget, netwidget,
        netwupwidget, netwdownwidget, wifiwidget,
        fshwidget, fsrwidget,
        memwidget,
        cputwidget,
        layout = awful.widget.layout.horizontal.rightleft }
end
-- }}}

