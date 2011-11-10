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
require("vicious")   -- (Non standard) System monitoring widgets

-- Start building config

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

