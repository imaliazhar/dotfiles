-- Applies the colorscheme and returns the lualine theme
vim.cmd.colorscheme("miasma")

local p = {
	bg = "#222222",
	surface = "#1c1c1c",
	overlay = "#444444",
	muted = "#666666",
	text = "#c2c2b0",
	sand = "#d7c483",
	green = "#5f875f",
	olive = "#78824b",
	orange = "#b36d43",
	copper = "#bb7744",
	gold = "#c9a554",
}

for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer" }) do
	local hl = vim.api.nvim_get_hl(0, { name = group })
	vim.api.nvim_set_hl(0, group, { fg = hl.fg, bg = "NONE" })
end

vim.api.nvim_set_hl(0, "FloatBorder", { fg = p.copper })

-- TS/JS color overrides
vim.api.nvim_set_hl(0, "@custom.imports", { fg = p.sand })
vim.api.nvim_set_hl(0, "@custom.type", { fg = p.olive })
vim.api.nvim_set_hl(0, "@custom.accessibility_modifier", { fg = p.olive })
vim.api.nvim_set_hl(0, "@custom.interface_declaration", { fg = p.olive })

local function mode(color)
	return {
		a = { bg = color, fg = p.bg, gui = "bold" },
		b = { bg = p.overlay, fg = color },
		c = { bg = p.surface, fg = p.text },
	}
end

return {
	normal = mode(p.olive),
	insert = mode(p.green),
	visual = mode(p.copper),
	replace = mode(p.orange),
	command = mode(p.gold),
	inactive = {
		a = { bg = p.surface, fg = p.muted, gui = "bold" },
		b = { bg = p.surface, fg = p.muted },
		c = { bg = p.surface, fg = p.muted },
	},
}
