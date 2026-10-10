local palette = {
	bg = "#222222",
	surface = "#1c1c1c",
	muted = "#666666",
	text = "#c2c2b0",
	sand = "#d7c483",
	brown = "#685742",
	green = "#5f875f",
	olive = "#78824b",
	orange = "#b36d43",
	copper = "#bb7744",
	gold = "#c9a554",
}

local ansi = {
	palette.bg,
	palette.brown,
	palette.green,
	palette.orange,
	palette.olive,
	palette.copper,
	palette.gold,
	palette.sand,
}

return {
	color_scheme = "Miasma",
	color_schemes = {
		Miasma = {
			foreground = palette.text,
			background = palette.bg,
			cursor_bg = palette.sand,
			cursor_fg = palette.bg,
			cursor_border = palette.sand,
			selection_bg = palette.olive,
			selection_fg = palette.bg,
			ansi = ansi,
			brights = { palette.muted, table.unpack(ansi, 2) },
		},
	},
	cursor_fg = palette.bg,
	cursor_bg = palette.sand,
	tab_bar_background = palette.surface,
	tab_bar_active_tab_bg_color = palette.surface,
	tab_bar_active_tab_fg_color = palette.sand,
	tab_bar_inactive_tab_bg_color = palette.surface,
	tab_bar_inactive_tab_fg_color = palette.muted,
	status_line_fg = palette.bg,
	status_line_bg = palette.copper,
	status_line_active = palette.text,
}
