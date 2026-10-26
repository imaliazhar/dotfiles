-- Iinstall the Hammerspoon CLI
require("hs.ipc")
local result = hs.ipc.cliInstall("/opt/homebrew", true)
hs.alert.show("Hammerspoon CLI installed: " .. tostring(result), 1)

local function sh(cmd)
	hs.task.new("/bin/zsh", nil, { "-lc", cmd }):start()
end

--- Runs `cmd`, retrying every second up to `tries` times until it exits zero.
local function sh_until_ok(cmd, tries)
	hs.task.new("/bin/zsh", function(code)
		if code ~= 0 and tries > 1 then
			hs.timer.doAfter(1, function()
				sh_until_ok(cmd, tries - 1)
			end)
		end
	end, { "-lc", cmd }):start()
end

local system_theme_watcher = require("system_theme_watcher")
system_theme_watcher:setup()

system_theme_watcher:add_listener(function(theme)
	hs.alert.show("Theme changed to " .. theme, 1)

	sh(([[~/.local/bin/theme %s]]):format(theme))
end)

local external_display_watcher = require("external_display_watcher")

-- (Re)start the status bars. They are detached from Hammerspoon, so a previous
-- instance survives a Hammerspoon restart and would block the new one from starting.
for _, bar in ipairs({ "sketchybar", "bottom_bar" }) do
	sh(([[killall %s 2>/dev/null; while pgrep -x %s >/dev/null; do sleep 0.1; done; nohup %s >/dev/null 2>&1 &]]):format(bar, bar, bar))
end

-- The top bar follows the external display; the bottom bar is only shown when a
-- second monitor is connected. Retries so the bar daemons have time to start.
local function apply_bars(count)
	sh_until_ok("sketchybar --bar display=" .. count, 10)
	sh_until_ok("bottom_bar --bar hidden=" .. (count > 1 and "false" or "true"), 10)
end

external_display_watcher:setup()
external_display_watcher:add_listener(apply_bars)
apply_bars(external_display_watcher.last_count)

-- hs.loadSpoon("EmmyLua")
