-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

--
--require("fullscreens")


-- Update theme first, so that font is reflected in all components
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.get_themes_dir() .. "zenburn/theme.lua")
local theme = beautiful.get()
theme.font = "droid 9"
theme.border_width = 1
theme.menu_width = 150
theme.menu_height = 18
beautiful.init(theme)


-- {{{ LAIN widgets
--
local lain = require("lain")
local spanGood = "<span foreground='#9ECE9E'>"
local spanMid  = "<span foreground='#F0DFAF'>"
local spanBad  = "<span foreground='#DFAF8F'>"
local spanClose = "</span>"

-- battery widget
local batwidget = lain.widget.bat({
  battery="BAT0",
  settings = function()
     -- icon config using font-awesome chars
     batterySpan  = spanGood
     if bat_now.status == "Charging" then
         batteryIcon = "<span font='FontAwesome'></span> "  
     else -- bat_now.status == "Discharging" then
         if bat_now.perc >= 90 then
             batteryIcon = "<span font='FontAwesome'></span> "
     elseif bat_now.perc >= 75 then
             batteryIcon = "<span font='FontAwesome'></span> "
         elseif bat_now.perc >= 50 then
             batteryIcon = "<span font='FontAwesome'></span> "
         elseif bat_now.perc >= 25 then
             batteryIcon = "<span font='FontAwesome'></span> "
             batterySpan = spanMid
         else
             batteryIcon = "<span font='FontAwesome'></span> "
             batterySpan = spanMid
         end
     end

     markup = batterySpan .. batteryIcon .. " " .. bat_now.perc .. "%" .. spanClose
     widget:set_markup(markup)

     awful.tooltip({
       objects = { widget },
       timer_function = function()
            return bat_now.status .. ': ' .. bat_now.time
        end,
     })
  end
})

-- wifi widget
local netwidget = wibox.widget.textbox()
local netstatus = lain.widget.net({
    notify = "on",
    wifi_state = "on",
    iface = "wlp2s0",
    settings = function()
        local wlan0 = net_now.devices.wlp2s0
        wifiIcon = "<span font='FontAwesome'></span> "
        wifiSpan  = spanBad
    signal = "off"
        if wlan0 then
            if wlan0.wifi then
                signal = wlan0.signal
                if signal < -83 then
                    wifiIcon = "<span font='FontAwesome'></span> "
                    wifiSpan  = spanBad
                elseif signal < -70 then
                    wifiIcon = "<span font='FontAwesome'></span> "
                    wifiSpan  = spanBad
                elseif signal < -53 then
                    wifiIcon = "<span font='FontAwesome'></span> "
                    wifiSpan  = spanMid
                elseif signal >= -53 then
             	    wifiIcon = "<span font='FontAwesome'></span> "
                    wifiSpan  = spanGood
                end
            else
             	wifiIcon = "<span font='FontAwesome'></span> "
                wifiSpan  = spanBad
            end
        end
        markup = wifiSpan .. wifiIcon .. " " .. signal .. spanClose
        netwidget:set_markup(markup)
    end
})

local volwidget = lain.widget.pulse({
    settings = function()
        volSpan  = spanGood
        volIcon = "<span font='FontAwesome'></span> "
        vlevel = volume_now.left .. "%" 
        if volume_now.muted == "yes" then
            volSpan  = spanBad
            volIcon = "<span font='FontAwesome'></span> "
        end
        markup = volSpan .. volIcon .. " " .. vlevel .. spanClose
        widget:set_markup(markup)
    end
})

volwidget.widget:buttons(awful.util.table.join(
    awful.button({}, 1, function() -- left click
        awful.spawn("pavucontrol")
    end),
    awful.button({}, 2, function() -- middle click
        os.execute(string.format("pactl set-sink-volume %d 100%%", volwidget.device))
        volwidget.update()
    end),
    awful.button({}, 3, function() -- right click
        os.execute(string.format("pactl set-sink-mute %d toggle",  volwidget.device))
        volwidget.update()
    end),
    awful.button({}, 4, function() -- scroll up
        os.execute(string.format("pactl set-sink-volume %d +1%%",  volwidget.device))
        volwidget.update()
    end),
    awful.button({}, 5, function() -- scroll down
        os.execute(string.format("pactl set-sink-volume %d -1%%",  volwidget.device))
        volwidget.update()
    end)    
))

local statusWidth = 75
batwidget.forced_width = statusWidth
netwidget.forced_width = statusWidth
volwidget.forced_width = statusWidth

local vertsep = wibox.widget.textbox("  |  ")
-- local vert_sep = wibox.widget {
--     widget = wibox.widget.separator,
--     orientation = "vertical",
--     forced_width = 2,
--     color = "#353535",
-- }

-- }}}

-- Custom Scratchpad
local scratch = require("scratch")

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



-- This is used later as the default terminal and editor to run.
terminal = os.getenv("TERMINAL") or "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- My bins
hbin = "$HOME/bin/"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.max,
--    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier,
--    awful.layout.suit.corner.nw,
--    awful.layout.suit.corner.ne,
--    awful.layout.suit.corner.sw,
--    awful.layout.suit.corner.se,
}
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
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end }
}

myprogs = {
   {"Chrome", "chrome"},
   {"PCManFM","pcmanfm"},
--   {"Thunar","thunar"},
   {"VLC", "vlc"},
   {"VirtualBox", "VirtualBox"},
--   {"VNC Gaia", "vncviewer 192.168.0.7"},
}

mypoweroptions = {
   { "nap",      "systemctl -q --no-block suspend" },
   { "suspend",  "susp" },
   { "reboot",   "systemctl -q --no-block reboot" },
   { "shutdown", "systemctl -q --no-block poweroff" },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "programme", myprogs },
                                    { "power", mypoweroptions },
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


-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = { "1 - main","2 - www","3 - mail","4 - file","5 - dev","6 - media"," 7 "," 8 "," 9 "," 0 "," ß "," ´ " }
-- }}}

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
--    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    awful.tag(tags, s, awful.layout.layouts[2])

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
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        --spacing = 5,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 10,
--            mykeyboardlayout,
            wibox.widget.systray(),
	          volwidget,
            batwidget,
	          netwidget,
            mytextclock,
            s.mylayoutbox,
        },
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
    awful.key({ }, "Pause", function ()
        awful.util.spawn("systemctl -q --no-block suspend") end),
    awful.key({ }, "XF86MonBrightnessDown", function ()
        awful.util.spawn("xbacklight -dec 5") end),
    awful.key({ }, "XF86MonBrightnessUp", function ()
        awful.util.spawn("xbacklight -inc 5") end),
    awful.key({ }, "XF86AudioMute", function ()
        os.execute(string.format("pactl set-sink-mute %d toggle",  volwidget.device))
        volwidget.update() end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
        os.execute(string.format("pactl set-sink-volume %d -5%%",  volwidget.device))
        volwidget.update() end),
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        os.execute(string.format("pactl set-sink-volume %d +5%%",  volwidget.device))
        volwidget.update() end),
    awful.key({ }, "XF86AudioMicMute", function ()
        os.execute(string.format("pactl set-sink-input-mute %d toggle",  volwidget.device))
        volwidget.update() end),
    awful.key({ modkey,           }, "i",      hotkeys_popup.show_help,
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
    awful.key({ modkey, "Control"   }, "Left", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Control"   }, "Right", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Shift" }, "Left", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Shift" }, "Right", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then
               client.focus:raise()
            end
        end,
        {description = "go to next client", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then
               client.focus:raise()
            end
        end,
        {description = "go to previous client", group = "client"}),
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
--    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
--              {description = "quit awesome", group = "awesome"}),

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
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
    awful.key( {}, "F12", function () scratch.drop(terminal, "top", "center", 0.8, 0.8, "sticky") end,
              {description = "launch sticky dropdown shell", group = "launcher"})

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
--    awful.key({ modkey,   "Shift" }, "f",
--	fullscreens(c)
--        {description = "toggle global fullscreen", group = "client"}),
    awful.key({ modkey            }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky          end,
              {description = "toggle sticky", group = "client"}),
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
-- 13 because 12 tags 1 -- ´. Original is 9
for i = 1, 13 do
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
                     size_hints_honor = false,
                     focus = awful.client.focus.filter,
--                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
--          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer",
          "Textext.py"},

        name = {
          "Event Tester",  -- xev.
          "Story Editor",  -- scribus.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
   { rule = { class = "chromium-public" },
      properties = { tag = tags[2] } },
   { rule = { class = "chromium-private" },
      properties = { tag = tags[3] } },
   { rule = { class = "Evince" },
      properties = { focus = false },
      callback = awful.client.setslave },
   { rule = { class = "okular" },
      properties = { focus = false },
      callback = awful.client.setslave },
   { rule = { class = "keepassxc" },
      properties = { floating = true }, },
   { rule = { name  = "Figure" },
      properties = { focus = false, floating = true, above = true },
      callback = awful.client.setslave },
   { rule = { class = "URxvt" },
      callback = awful.client.setslave },
   { rule = { class = "Sxiv" },
      callback = awful.client.setslave },
   { rule = { class  = "Pavucontrol" },
     properties = { floating = true,
                     width  = 800,
                     height = 600 } },
   { rule = { role  = "pop-up" },
      properties = { floating = true,
                     size_hints_honor = true },
      callback = function(c) awful.placement.centered(c) end },
   { rule = { role  = "EventDialog" },
      properties = { floating = true,
                     size_hints_honor = true },
      callback = function(c) awful.placement.centered(c) end }
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

client.connect_signal("focus", function(c) c.border_color = beautiful.border_marked end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
