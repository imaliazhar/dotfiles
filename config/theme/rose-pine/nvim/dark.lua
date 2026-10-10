-- Applies the colorscheme and returns the lualine theme
vim.cmd.colorscheme("rose-pine-moon")

local p = require("rose-pine.palette")
local cursorline = "#1f1d2e"

vim.api.nvim_set_hl(0, "@custom.imports", { fg = p.text })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = p.rose })

vim.cmd.highlight("CursorLine guibg=" .. cursorline)

local LspInlayHint = vim.api.nvim_get_hl(0, { name = "LspInlayHint" })
vim.api.nvim_set_hl(0, "LspInlayHint", { fg = LspInlayHint.fg, bg = "NONE" })

-- TS/JS color overrides
vim.api.nvim_set_hl(0, "@custom.type", { fg = p.pine })
vim.api.nvim_set_hl(0, "@custom.accessibility_modifier", { fg = p.pine })
vim.api.nvim_set_hl(0, "@custom.interface_declaration", { fg = p.pine })

return {
	normal = {
		a = { bg = p.rose, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.rose },
		c = { bg = p.surface, fg = p.text },
	},
	insert = {
		a = { bg = p.foam, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.foam },
		c = { bg = p.surface, fg = p.text },
	},
	visual = {
		a = { bg = p.iris, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.iris },
		c = { bg = p.surface, fg = p.text },
	},
	replace = {
		a = { bg = p.pine, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.pine },
		c = { bg = p.surface, fg = p.text },
	},
	command = {
		a = { bg = p.love, fg = p.base, gui = "bold" },
		b = { bg = p.overlay, fg = p.love },
		c = { bg = p.surface, fg = p.text },
	},
	inactive = {
		a = { bg = p.surface, fg = p.muted, gui = "bold" },
		b = { bg = p.surface, fg = p.muted },
		c = { bg = p.surface, fg = p.muted },
	},
}
