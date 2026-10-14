local wezterm = require("wezterm")
local action = wezterm.action

-- Shared WezTerm shortcuts. setup_keymap() appends the tmux bindings below.
local keymap = {
	-- Terminal

	-- Cmd+Q -> quit WezTerm.
	{
		key = "q",
		mods = "CMD",
		action = wezterm.action.QuitApplication,
	},

	-- Cmd+Shift+N -> open a new window.
	{
		key = "n",
		mods = "SUPER|SHIFT",
		action = action.SpawnWindow,
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

local module = {}

-- Appends the tmux bindings and installs the final key table into WezTerm.
function module.setup_keymap(config)
	for _, v in ipairs(tmux) do
		table.insert(keymap, v)
	end

	config.disable_default_key_bindings = true
	config.keys = keymap
end

return module
