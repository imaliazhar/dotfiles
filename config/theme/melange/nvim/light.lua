-- Applies the colorscheme and returns the lualine theme
vim.o.background = "light"
vim.g.melange_enable_font_variants = { bold = true, italic = false, underline = true, undercurl = true, strikethrough = true }
vim.cmd.colorscheme("melange")

for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "EndOfBuffer" }) do
	local hl = vim.api.nvim_get_hl(0, { name = group })
	vim.api.nvim_set_hl(0, group, { fg = hl.fg, bg = "NONE" })
end

vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#A98A78" })

package.loaded["lualine.themes.melange"] = nil
return require("lualine.themes.melange")
