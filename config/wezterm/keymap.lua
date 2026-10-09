local wezterm = require("wezterm")
local workspaces = require("workspaces")
local utils = require("utils")
local action = wezterm.action

-- Shared WezTerm shortcuts that are always loaded. setup_keymap() appends
-- either the real tmux bindings or the WezTerm-native tmux emulation below.
local keymap = {
	-- Terminal

	-- Cmd+Q -> quit WezTerm.
	{
		key = "q",
		mods = "CMD",
		action = wezterm.action.QuitApplication,
	},

	-- Cmd+C -> copy the current terminal selection to the system clipboard.
	{
		key = "c",
		mods = "SUPER",
		action = action.CopyTo("Clipboard"),
	},

	-- Cmd+V -> paste from the system clipboard.
	{
		key = "v",
		mods = "SUPER",
		action = action.PasteFrom("Clipboard"),
	},

	-- Cmd+_ (Cmd+Shift+-) -> decrease font size.
	{
		key = "_",
		mods = "SUPER",
		action = action.DecreaseFontSize,
	},

	-- Cmd++ -> increase font size.
	{
		key = "+",
		mods = "SUPER",
		action = action.IncreaseFontSize,
	},

	-- Cmd+= -> reset font size.
	{
		key = "=",
		mods = "SUPER",
		action = action.ResetFontSize,
	},

	-- Cmd+Ctrl+F -> toggle native fullscreen.
	{
		key = "f",
		mods = "SUPER|CTRL",
		action = action.ToggleFullScreen,
	},

	-- Cmd+- -> tmux prefix + -: split the tmux pane downward at 30% (tmux.conf).
	{
		mods = "SUPER",
		key = "-",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "-" }),
		}),
	},
	-- Cmd+\ -> tmux prefix + \: split the tmux pane to the right at 30% (tmux.conf).
	{
		mods = "SUPER",
		key = "\\",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "\\" }),
		}),
	},

	-- Editor / tmux helpers
	-- Neovim leader is Space (see config/nvim/lua/config/keybindings.lua).

	-- {
	-- 	key = "w",
	-- 	mods = "SUPER",
	-- 	action = action.Multiple({
	-- 		action.SendKey({ key = " " }),
	-- 		action.SendKey({ key = "w" }),
	-- 	}),
	-- },

	-- Cmd+G -> tmux prefix + g: run editor-git from tmux.conf. lazygit
	{
		key = "g",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "g" }),
			action.SendKey({ key = "g" }),
		}),
	},

	-- Cmd+/ -> Neovim <Leader>/: toggle comments for the current line/selection.
	{
		key = "/",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "/" }),
		}),
	},

	-- {
	-- 	key = "s",
	-- 	mods = "SUPER",
	-- 	action = action.Multiple({
	-- 		action.SendKey({ key = " " }),
	-- 		action.SendKey({ key = "s" }),
	-- 	}),
	-- },
	-- Cmd+Shift+S -> Neovim <Leader>S: save without formatting.
	{
		key = "s",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "S" }),
		}),
	},

	-- Cmd+P -> Neovim <Leader><C-f>: open the FFF/file picker.
	{
		key = "p",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "f", mods = "CTRL" }),
		}),
	},

	-- Cmd+F -> Neovim <Leader>f: live grep/search project text.
	{
		key = "f",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "f" }),
		}),
	},

	-- Cmd+E -> Neovim <Leader>e: open the Yazi file explorer.
	{
		key = "e",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = " " }),
			action.SendKey({ key = "e" }),
		}),
	},

	-- Cmd+Ctrl+L -> open WezTerm's debug overlay.
	{ key = "l", mods = "CTRL|SUPER", action = wezterm.action.ShowDebugOverlay },
}

-- Real tmux shortcuts: active when emulate_tmux = false in config/wezterm/wezterm.lua.
-- These send your tmux prefix (`) plus a tmux key; linked bindings are in config/tmux/tmux.conf.
local tmux = {
	-- Cmd+U -> tmux prefix + u: scroll one page up in tmux copy mode (tmux.conf).
	{
		key = "u",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "u" }),
		}),
	},

	-- Cmd+D -> tmux prefix + d: scroll one page down in tmux copy mode (tmux.conf).
	{
		key = "d",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "d" }),
		}),
	},

	-- Cmd+S -> tmux prefix + s: trigger tmux-leap (configured by @leap-key in tmux.conf).
	{
		key = "s",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "s" }),
		}),
	},

	-- Cmd+R -> tmux prefix + r: open the tmux session selector popup (tmux.conf).
	{
		key = "r",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "r" }),
		}),
	},

	-- Cmd+' -> tmux prefix + r: open the tmux session selector popup (same as Cmd+R).
	{
		key = "'",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "r" }),
		}),
	},

	-- Cmd+T -> tmux prefix + t: create a new tmux window (tmux.conf).
	{
		key = "t",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "t" }),
		}),
	},

	-- Cmd+Shift+T -> tmux prefix + T: create a new window in the current pane path (tmux.conf).
	{
		key = "T",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "T" }),
		}),
	},

	-- Cmd+Shift+J -> tmux prefix + ): switch to the next tmux session.
	{
		key = "j",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = ")" }),
		}),
	},

	-- Cmd+Shift+K -> tmux prefix + (: switch to the previous tmux session.
	{
		key = "k",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "(" }),
		}),
	},

	-- Cmd+Shift+L -> tmux prefix + >: move the current tmux window one index right.
	{
		key = "l",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = ">" }),
		}),
	},

	-- Cmd+Shift+H -> tmux prefix + <: move the current tmux window one index left.
	{
		key = "h",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "<" }),
		}),
	},

	-- Cmd+L -> tmux prefix + n: switch to the next tmux window.
	{
		key = "l",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "n" }),
		}),
	},

	-- Cmd+H -> tmux prefix + p: switch to the previous tmux window.
	{
		key = "h",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "p" }),
		}),
	},

	-- Cmd+Z -> tmux prefix + z: zoom/unzoom the active pane.
	{
		key = "z",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "z" }),
		}),
	},

	-- Cmd+O -> tmux prefix + c: open the recent Claude session picker (tmux.conf).
	{
		key = "o",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "c" }),
		}),
	},

	-- Cmd+Shift+p -> tmux prefix + G: toggle the ghpr popup (tmux.conf).
	{
		key = "p",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "G" }),
		}),
	},

	-- Cmd+J -> tmux prefix + ): switch to the next tmux session.
	{
		key = "j",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = ")" }),
		}),
	},

	-- Cmd+K -> tmux prefix + (: switch to the previous tmux session.
	{
		key = "k",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "(" }),
		}),
	},

	-- Cmd+Shift+; (:) -> tmux prefix + L: switch to the last-used tmux session.
	-- WezTerm sees shifted semicolon as ":", so the trigger key must be ":".
	{
		key = ":",
		mods = "SUPER|SHIFT",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "L" }),
		}),
	},

	-- Cmd+; -> tmux prefix + l: switch to the last-used tmux window.
	{
		key = ";",
		mods = "SUPER",
		action = action.Multiple({
			action.SendKey({ key = "`" }),
			action.SendKey({ key = "l" }),
		}),
	},
}

local function move_tab_clamped(delta)
	return wezterm.action_callback(function(window, pane)
		local tabs = window:mux_window():tabs_with_info()
		for _, info in ipairs(tabs) do
			if info.is_active then
				local target = info.index + delta
				if target >= 0 and target < #tabs then
					window:perform_action(action.MoveTab(target), pane)
				end
				return
			end
		end
	end)
end

-- WezTerm-native tmux emulation: active when emulate_tmux = true.
-- These use WezTerm tabs, panes, mux domains, and workspaces instead of real tmux.
local tmux_emulated = {
	-- Ctrl+G -> disable any WezTerm default so Ctrl+G can pass through to terminal apps.
	{
		key = "g",
		mods = "CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},
	-- Cmd+[ -> enter WezTerm copy mode, mirroring tmux prefix + [.
	{
		key = "[",
		mods = "SUPER",
		action = wezterm.action.ActivateCopyMode,
	},

	-- Cmd+F -> zoom/unzoom the active WezTerm pane.
	{
		key = "f",
		mods = "SUPER",
		action = action.TogglePaneZoomState,
	},

	-- Cmd+T -> spawn a new WezTerm tab in the current pane domain.
	{
		key = "t",
		mods = "SUPER",
		action = action.SpawnTab("CurrentPaneDomain"),
	},
	-- Cmd+L -> activate the next WezTerm tab.
	{
		key = "l",
		mods = "SUPER",
		action = action.ActivateTabRelative(1),
	},
	-- Cmd+H -> activate the previous WezTerm tab.
	{
		key = "h",
		mods = "SUPER",
		action = action.ActivateTabRelative(-1),
	},

	-- Cmd+Shift+L -> move the active WezTerm tab one position right.
	{
		key = "l",
		mods = "SUPER|SHIFT",
		action = move_tab_clamped(1),
	},
	-- Cmd+Shift+H -> move the active WezTerm tab one position left.
	{
		key = "h",
		mods = "SUPER|SHIFT",
		action = move_tab_clamped(-1),
	},

	-- Cmd+G -> open lazygit in a new WezTerm tab.
	{
		key = "g",
		mods = "SUPER",
		action = action.SpawnCommandInNewTab({
			args = { "zsh", "-l", "-c", "lazygit" },
		}),
	},

	-- {
	-- 	key = "g",
	-- 	mods = "SUPER",
	-- 	action = action.Multiple({
	-- 		action.SendKey({ key = " " }),
	-- 		action.SendKey({ key = "l" }),
	-- 		action.SendKey({ key = "g" }),
	-- 	}),
	-- },
	--
	-- Cmd+I -> move focus to the previous WezTerm pane.
	{
		key = "i",
		mods = "SUPER",
		action = action.ActivatePaneDirection("Prev"),
	},
	-- Cmd+O -> move focus to the next WezTerm pane.
	{
		key = "o",
		mods = "SUPER",
		action = action.ActivatePaneDirection("Next"),
	},

	-- Cmd+, -> prompt for a new WezTerm tab name.
	{
		key = ",",
		mods = "SUPER",
		action = action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- {
	-- 	key = "w",
	-- 	mods = "SUPER",
	-- 	action = action.ShowTabNavigator,
	-- },

	-- Cmd+X -> close the current WezTerm tab without confirmation.
	{
		key = "x",
		mods = "SUPER",
		action = action.CloseCurrentTab({ confirm = false }),
	},

	-- Cmd+- -> split the current WezTerm pane downward at 30%.
	{
		key = "-",
		mods = "SUPER",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 30 },
		}),
	},
	-- Cmd+\ -> split the current WezTerm pane to the right at 30%.
	{
		key = "\\",
		mods = "SUPER",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 30 },
		}),
	},
	{
		-- Cmd+Shift+[ ({) -> choose a pane and swap it with the active pane.
		key = "{",
		mods = "SUPER|SHIFT",
		action = action.PaneSelect({ mode = "SwapWithActiveKeepFocus" }),
	},

	-- Leader+A -> attach to the local WezTerm mux domain ("unix").
	{
		key = "a",
		mods = "LEADER",
		action = action.AttachDomain("unix"),
	},

	-- Leader+D -> detach from the local WezTerm mux domain ("unix").
	{
		key = "d",
		mods = "LEADER",
		action = action.DetachDomain({ DomainName = "unix" }),
	},

	-- Leader+Shift+4 ($) -> prompt for a new WezTerm workspace/session name.
	{
		key = "$",
		mods = "LEADER|SHIFT",
		action = action.PromptInputLine({
			description = "Enter new name for session",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
				end
			end),
		}),
	},

	-- {
	-- 	key = "j",
	-- 	mods = "SHIFT|SUPER",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local active_workspace = wezterm.mux.get_active_workspace()
	-- 		wezterm.mux.increment_workspace_order(active_workspace)
	-- 		local status = workspaces.get_current_workspace_label(window)
	-- 		window:set_right_status(status)
	-- 	end),
	-- },
	--
	-- {
	-- 	key = "k",
	-- 	mods = "SHIFT|SUPER",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local active_workspace = wezterm.mux.get_active_workspace()
	-- 		wezterm.mux.decrement_workspace_order(active_workspace)
	-- 		local status = workspaces.get_current_workspace_label(window)
	-- 		window:set_right_status(status)
	-- 	end),
	-- },

	-- Cmd+Shift+K -> switch to the next WezTerm workspace/session.
	{ key = "k", mods = "SHIFT|SUPER", action = action.SwitchWorkspaceRelative(1) },
	-- Cmd+Shift+J -> switch to the previous WezTerm workspace/session.
	{ key = "j", mods = "SHIFT|SUPER", action = action.SwitchWorkspaceRelative(-1) },

	-- Cmd+R -> open a fuzzy selector for WezTerm workspaces/sessions.
	{
		key = "r",
		mods = "SUPER",
		action = wezterm.action_callback(function(window, pane)
			local workspace_list = workspaces.get_all_workspaces()

			local choices = {}

			for _, ws in ipairs(workspace_list) do
				local data = utils.split(ws, "|")
				local marker, name = data[1], data[2]
				local is_active = marker == "o"

				if is_active then
					name = wezterm.format({
						{ Foreground = { AnsiColor = "Fuchsia" } },
						{ Text = name },
					})
				end

				table.insert(choices, { label = name, id = ws })
			end

			window:perform_action(
				action.InputSelector({
					action = wezterm.action_callback(function(inner_window, inner_pane, id)
						if not id then
							wezterm.log_info("cancelled")
						else
							wezterm.log_info("id = " .. id)

							local data = utils.split(id, "|")
							local name, path = data[2], data[3]

							inner_window:perform_action(workspaces.select_workspace(name, path), inner_pane)
						end
					end),
					title = "Workspace",
					choices = choices,
					fuzzy = true,
					fuzzy_description = "Select: ",
				}),
				pane
			)
		end),
	},
	-- Leader+Cmd+Ctrl+R -> prompt for a new WezTerm tab name.
	{
		key = "r",
		mods = "LEADER|CTRL|SUPER",
		action = action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}

for i = 1, 8 do
	-- Leader+Cmd+Ctrl+number -> move the active tab to that tab index (1-8).
	table.insert(tmux_emulated, {
		key = tostring(i),
		mods = "LEADER|CTRL|SUPER",
		action = wezterm.action.MoveTab(i - 1),
	})
end

local module = {}

-- Appends the mode-specific bindings and installs the final key table into WezTerm.
function module.setup_keymap(config, emulate_tmux)
	if emulate_tmux then
		for _, v in ipairs(tmux_emulated) do
			table.insert(keymap, v)
		end
	else
		for _, v in ipairs(tmux) do
			table.insert(keymap, v)
		end
	end

	if emulate_tmux then
		config.leader = { key = "`", mods = "NONE", timeout_milliseconds = 1000 }
	end

	config.disable_default_key_bindings = true
	config.keys = keymap
end

return module
