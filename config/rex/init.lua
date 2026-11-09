---@diagnostic disable: undefined-global

-- Tab and session history
-- Each binding below records where you are before it switches, so cmd+; and
-- shift+cmd+; can jump back. Clicks in the app aren't recorded, and the
-- history resets when the config reloads.
local history = {}

local function current_location(session_id)
	local view = rex.session.view({ session_id = session_id })
	return { session = session_id, window = view and view.active_window_id }
end

local function remember(location)
	local top = history[#history]
	if top and top.session == location.session and top.window == location.window then
		return
	end
	table.insert(history, location)
	if #history > 50 then
		table.remove(history, 1)
	end
end

local function jump_back(ctx, matches)
	local here = current_location(ctx.session_id)
	for i = #history, 1, -1 do
		local location = history[i]
		if matches(location, here) then
			remember(here)
			rex.client.queue("session.select", { session_id = location.session, window_id = location.window })
			return
		end
	end
end

local function tracked(name, title, client_action, args)
	rex.action({
		name = name,
		title = title,
		run = function(ctx)
			remember(current_location(ctx.session_id))
			rex.client.queue(client_action, args)
		end,
	})
end

-- Tabs
tracked("tab_previous", "Previous Tab", "client.tab.previous")
tracked("tab_next", "Next Tab", "client.tab.next")
rex.bind("cmd+k", "tab_previous")
rex.bind("cmd+j", "tab_next")

for i = 1, 9 do
	tracked("tab_goto_" .. i, "Go to Tab " .. i, "client.tab.goto", { index = i })
	rex.bind("cmd+" .. i, "tab_goto_" .. i)
end

rex.action({
	name = "tab_last",
	title = "Last Tab",
	run = function(ctx)
		jump_back(ctx, function(location, here)
			return location.session == here.session and location.window ~= here.window
		end)
	end,
})
rex.bind("cmd+;", "tab_last")

-- Sessions
tracked("session_previous", "Previous Session", "session.previous")
tracked("session_next", "Next Session", "session.next")
tracked("session_picker", "Change Session", "session.switch")
rex.bind("shift+cmd+k", "session_previous")
rex.bind("shift+cmd+j", "session_next")

rex.action({
	name = "session_last",
	title = "Last Session",
	run = function(ctx)
		jump_back(ctx, function(location, here)
			return location.session ~= here.session
		end)
	end,
})
rex.bind("shift+cmd+;", "session_last")

rex.action({
	name = "session_remember",
	title = "Remember Session",
	args = { session_id = "string" },
	run = function(_, args)
		remember(current_location(args.session_id))
	end,
})

-- Panes
rex.bind("alt+cmd+h", "pane.focus.left")
rex.bind("alt+cmd+j", "pane.focus.down")
rex.bind("alt+cmd+k", "pane.focus.up")
rex.bind("alt+cmd+l", "pane.focus.right")

-- Resize mode
rex.mode("resize", { exclusive = true })
rex.bind("alt+cmd+r", "client.mode.enter", { name = "resize" })

local resize_keys = {
	left = { "h", "left" },
	down = { "j", "down" },
	up = { "k", "up" },
	right = { "l", "right" },
}
for direction, keys in pairs(resize_keys) do
	for _, key in ipairs(keys) do
		rex.bind("resize/" .. key, "pane.resize", { direction = direction })
		rex.bind("resize/shift+" .. key, "pane.resize", { direction = direction, amount = 15 })
	end
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")

-- Font size
rex.bind("cmd+=", "client.font.increase")
rex.bind("cmd+-", "client.font.decrease")
rex.bind("shift+cmd+=", "client.font.reset")

-- Neovim leader shortcuts
rex.action({
	name = "type_keys",
	title = "Type Keys",
	description = "Type the given text into the focused pane",
	args = { data = "string" },
	run = function(ctx, args)
		rex.block.call("com.superlogical.terminal", "write", { block_id = ctx.block_id, data = args.data })
	end,
})

rex.bind("cmd+p", "type_keys", { data = " \6" }) -- <Space><C-f> file picker
rex.bind("cmd+e", "type_keys", { data = " e" }) -- <Space>e Yazi

-- Floating panes
local terminal = "com.superlogical.terminal"

local function focused_pwd(ctx)
	local ok, res = pcall(rex.block.call, terminal, "pwd", { block_id = ctx.block_id })
	if not ok or not res or not res.pwd then
		return nil
	end
	local path = res.pwd:match("^file://[^/]*(/.*)$") or res.pwd
	return (path:gsub("%%(%x%x)", function(hex)
		return string.char(tonumber(hex, 16))
	end))
end

local function float(ctx, command, bounds)
	local _, err = rex.session.new_layer({
		bounds = bounds or { 0, 0, 1, 1 },
		focus = true,
		layout = rex.layout.block({
			flavor = "com.superlogical.terminal.shell",
			options = { command = command, cwd = focused_pwd(ctx) },
		}),
	})
	if err ~= nil then
		error(err, 0)
	end
end

rex.action({
	name = "lazygit",
	title = "Lazygit",
	run = function(ctx)
		float(ctx, { "lazygit" })
	end,
})

rex.bind("alt+cmd+g", "lazygit")

rex.action({
	name = "yazi",
	title = "Yazi",
	run = function(ctx)
		float(ctx, { "yazi" }, { 0.1, 0.1, 0.8, 0.8 })
	end,
})

rex.bind("shift+cmd+e", "yazi")

rex.action({
	name = "open_project",
	title = "Open Project",
	run = function(ctx)
		float(ctx, { os.getenv("HOME") .. "/Dotfiles/scripts/rex-open-project.sh" }, { 0.25, 0.2, 0.5, 0.6 })
	end,
})

rex.bind("shift+cmd+l", "open_project")
rex.bind("cmd+l", "session_picker")
