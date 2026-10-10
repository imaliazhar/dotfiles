-- Applies the colorscheme and returns the lualine theme
vim.o.background = "dark"
vim.g.melange_enable_font_variants = { bold = true, italic = false, underline = true, undercurl = true, strikethrough = true }
vim.cmd.colorscheme("melange")

for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer" }) do
	local hl = vim.api.nvim_get_hl(0, { name = group })
	vim.api.nvim_set_hl(0, group, { fg = hl.fg, bg = "NONE" })
end

vim.api.nvim_set_hl(0, "CursorLine", { bg = "#211D1A" })

vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#867462" })

package.loaded["lualine.themes.melange"] = nil
local theme = require("lualine.themes.melange")

for _, mode in pairs(theme) do
	mode.c.bg = "#211D1A"
end

return theme
