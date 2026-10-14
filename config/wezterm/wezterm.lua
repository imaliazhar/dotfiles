local wezterm = require("wezterm")
local theme = require("theme")

local config = wezterm.config_builder()

local keymap = require("keymap")
keymap.setup_keymap(config)

-- config.font = wezterm.font("Iosevka", { weight = "Regular" })
-- config.font = wezterm.font("Monolisa", { weight = "Regular" })
-- config.font = wezterm.font("Dank Mono", { weight = "Regular" })
config.font = wezterm.font("Victor Mono", { weight = "Medium" })

config.font_size = 17
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.color_schemes = theme.color_schemes
config.color_scheme = theme.color_scheme

config.colors = {
	cursor_fg = theme.cursor_fg,
	cursor_bg = theme.cursor_bg,
	tab_bar = {
		background = theme.tab_bar_background,
		active_tab = {
			bg_color = theme.tab_bar_active_tab_bg_color,
			fg_color = theme.tab_bar_active_tab_fg_color,
			intensity = "Bold", -- "Half", "Normal", "Bold"
			underline = "None", -- "None", "Single", "Double"
			italic = false,
			strikethrough = false,
		},
		inactive_tab = {
			bg_color = theme.tab_bar_inactive_tab_bg_color,
			fg_color = theme.tab_bar_inactive_tab_fg_color,
		},
	},
}

config.use_resize_increments = false
config.adjust_window_size_when_changing_font_size = false

-- config.force_reverse_video_cursor = true
config.pane_focus_follows_mouse = true
config.scrollback_lines = 5000

config.enable_tab_bar = false

config.window_background_opacity = 0.90
config.macos_window_background_blur = 50
config.window_close_confirmation = "NeverPrompt"
config.native_macos_fullscreen_mode = true
config.window_decorations = "RESIZE|MACOS_FORCE_ENABLE_SHADOW"
config.debug_key_events = false
config.max_fps = 120

-- Sync ~.local/bin/nvr
config.set_environment_variables = { MUX = "tmux" }

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	overrides.window_background_opacity = window:is_focused() and config.window_background_opacity or 0.96
	window:set_config_overrides(overrides)
end)

return config
