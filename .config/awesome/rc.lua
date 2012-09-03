-------------------------------
--
-- Marco's Awesome WM config
--
--
-- Based on:
-- https://github.com/JackH79/.dotfiles/blob/master/.config/awesome/rc.lua
--
-------------------------------

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful") -- Theme handling library
require("naughty")   -- Notification library
vicious = require("vicious")   -- (Non standard) System monitoring widgets

-- Start building config

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
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end

--setup_runtime_error_handler()
-- }}}

require("awrc.defaults")
require("awrc.themes")
require("awrc.tags")
require("awrc.menu")
require("awrc.widgets")
require("awrc.bindings")
require("awrc.rules")
require("awrc.signals")
require("awrc.autostart")

-- End of config

