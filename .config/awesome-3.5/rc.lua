-------------------------------
--
-- Marco's Awesome 3.5 WM config
--
-------------------------------

-- Standard awesome library
gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
menubar = require("menubar")

-- {{{ Error handling
-- Don't put this in another file, as awesome would not indicate an error
-- if there is a problem with that particular require.
--
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
function setup_runtime_error_handler()
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

setup_runtime_error_handler()
-- }}}

require("awrc.defaults")
require("awrc.themes")
require("awrc.tags")
require("awrc.menu")
require("awrc.widgets")
require("awrc.bindings")
require("awrc.signals")
require("awrc.rules")
require("awrc.autostart")

