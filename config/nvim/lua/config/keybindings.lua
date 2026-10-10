vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set

-- Keep cursor/window position after any yank.
local pre_yank_view = {}
local function save_pre_yank_view()
	pre_yank_view[vim.api.nvim_get_current_win()] = vim.fn.winsaveview()
end

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "WinEnter", "CursorMoved" }, {
	callback = save_pre_yank_view,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		if vim.v.event.operator == "y" then
			local view = pre_yank_view[vim.api.nvim_get_current_win()]
			if view then
				vim.fn.winrestview(view)
			end
		end
	end,
})

vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })
vim.keymap.set("v", "j", "gj", { noremap = true })
vim.keymap.set("v", "k", "gk", { noremap = true })

-- Buffer Navigation
map({ "n", "v" }, "gh", "<CMD>bprev<CR>", { desc = "Jump to previous buffer" })
map({ "n", "v" }, "gl", "<CMD>bnext<CR>", { desc = "Jump to next buffer" })
map({ "n", "v" }, "<Leader>d", vim.diagnostic.setqflist, { desc = "List diagnostics" })

-- Buffer Management
map({ "n", "v" }, "<Leader>r", ":e!<CR>", { desc = "Reload buffer" })
map({ "n", "v" }, "<Leader>w", ":bd<CR>", { desc = "Close buffer" })
map({ "n", "v" }, "<Leader>W", ":%bd<CR>", { desc = "Close all buffers" })
map({ "n", "v" }, "<leader>s", "<CMD>w<CR>", { desc = "Save file" })
map({ "n", "v" }, "<leader>S", "<CMD>:noa w<CR>", { desc = "Save file without formatting" })

map({ "n", "v" }, "<Leader>bn", ":bn<CR>", { desc = "Next buffer" })
map({ "n", "v" }, "<Leader>bp", ":bp<CR>", { desc = "Previous buffer" })

map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

map("n", "<Leader>*", function()
	vim.cmd("vim /" .. vim.fn.expand("<cword>") .. "/ % | cw")
end, { noremap = true, silent = true, desc = "Search current word in current file" })
map("v", "<localleader>8", ":s#^\\(.*\\)$#", { noremap = true, silent = true, desc = "Create capture group" })

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		-- Add New Line
		map("n", "<CR>", "o<Esc>", { desc = "Add new line below (normal mode)" })
	end,
})
vim.api.nvim_create_autocmd("CmdwinEnter", {
	callback = function()
		-- Reset New Line binding in command window
		map("n", "<CR>", "<CR>", { buffer = true })
	end,
})

-- Marks Management
map("n", "M", "m", { desc = "Set mark" })
map("n", "m", "'", { desc = "Jump to mark" })
-- ' is used for buffer navigation

-- Comment Actions
map("n", "<leader>/", "gcl", { remap = true, desc = "Toggle comment (current line)" })
map("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment (selection)" })

-- Pi @ai Annotations
local AI_LINE = "@ai "
local AI_START = "@ai:start "
local AI_END = "@ai:end"

local function start_insert_at_marker_end(row, marker)
	vim.schedule(function()
		vim.api.nvim_win_set_cursor(0, { row, math.max(#marker - 1, 0) })
		vim.cmd("startinsert!")
	end)
end

map("n", "<leader>ai", function()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { AI_LINE })
	start_insert_at_marker_end(row, AI_LINE)
end, { desc = "Add @ai annotation before current line" })

map("x", "<leader>ai", function()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	vim.cmd("normal! \27")
	vim.api.nvim_buf_set_lines(0, end_line, end_line, false, { AI_END })
	vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, { AI_START })
	start_insert_at_marker_end(start_line, AI_START)
end, { desc = "Wrap selection with @ai range" })

-- Clipboard Actions
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
map({ "n", "v" }, "<Leader>p", '"+p', { desc = "Paste from system clipboard after cursor" })
map({ "n", "v" }, "<Leader>P", '"+P', { desc = "Paste from system clipboard before cursor" })

map("v", "<CR>", '"+y', { desc = "Copy selection to clipboard" })

-- Line Navigation
map({ "n", "v", "x", "o" }, "H", "^", { desc = "Go to beginning of line" })
map({ "n", "v", "x", "o" }, "L", "$", { desc = "Go to end of line" })

-- map("n", "m", "'", { noremap = true, silent = true })
-- map("n", "M", "m", { noremap = true, silent = true })

-- Lua Execution
map("n", "<leader><leader>el", function()
	vim.cmd("source %")
	vim.notify("Executed current Lua file", vim.log.levels.INFO)
end, { desc = "Execute current lua file" })

-- Reload theme
map("n", "<leader><leader>rt", function()
	vim.cmd("source ~/.config/nvim/after/plugin/theme.lua")
end, { desc = "Reload theme" })

-- map("n", "<leader>el", ":.lua<CR>", { desc = "Execute current lua line" })
-- map("v", "<leader>el", ":lua<CR>", { desc = "Execute selected lua line" })

-- Copy Current File Info
map("n", "<leader>cf", function()
	local filename = vim.fn.expand("%:t:r")
	vim.fn.setreg("+", filename)
end, { desc = "Copy current file name", noremap = true, silent = true })

map("n", "<leader>cF", function()
	local filename = vim.fn.expand("%:t")
	vim.fn.setreg("+", filename)
end, { desc = "Copy current file name with extension", noremap = true, silent = true })

map("n", "<leader>cp", function()
	local filepath = vim.fn.expand("%")
	local home = vim.fn.expand("$HOME")
	filepath = filepath:gsub("^" .. home, "~")
	vim.fn.setreg("+", filepath)
end, { desc = "Copy current file path", noremap = true, silent = true })

map("n", "<leader>cP", function()
	local filepath = vim.fn.expand("%:p")
	local home = vim.fn.expand("$HOME")
	filepath = filepath:gsub("^" .. home, "~")
	vim.fn.setreg("+", filepath)
end, { desc = "Copy current file's absolute path", noremap = true, silent = true })

map("n", "<leader>cl", function()
	local filepath = vim.fn.expand("%")
	local home = vim.fn.expand("$HOME")
	filepath = filepath:gsub("^" .. home, "~")
	local line = vim.fn.line(".")
	vim.fn.setreg("+", filepath .. ":" .. line)
end, { desc = "Copy current file path with line number", noremap = true, silent = true })

map("n", "<leader>cL", function()
	local filepath = vim.fn.expand("%:p")
	local home = vim.fn.expand("$HOME")
	filepath = filepath:gsub("^" .. home, "~")
	local line = vim.fn.line(".")
	vim.fn.setreg("+", filepath .. ":" .. line)
end, { desc = "Copy current file's absolute path with line number", noremap = true, silent = true })

map("v", "<leader>cl", function()
	local filepath = vim.fn.expand("%")
	local home = vim.fn.expand("$HOME")
	filepath = filepath:gsub("^" .. home, "~")
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	vim.fn.setreg("+", filepath .. ":" .. start_line .. "-" .. end_line)
end, { desc = "Copy current file path with line range", noremap = true, silent = true })

map("v", "<leader>cL", function()
	local filepath = vim.fn.expand("%:p")
	local home = vim.fn.expand("$HOME")
	filepath = filepath:gsub("^" .. home, "~")
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	vim.fn.setreg("+", filepath .. ":" .. start_line .. "-" .. end_line)
end, { desc = "Copy current file's absolute path with line range", noremap = true, silent = true })

map("n", "<leader>cr", function()
	local root = vim.fn.getcwd()
	local home = vim.fn.expand("$HOME")
	root = root:gsub("^" .. home, "~")
	vim.fn.setreg("+", root)
end, { desc = "Copy root folder path", noremap = true, silent = true })

-- Diffview Integration
map({ "n", "v" }, "<Leader>gg", ":DiffviewOpen<CR>", { desc = "Open diff view" })
map({ "n", "v" }, "<Leader>gd", ":DiffviewClose<CR>", { desc = "Close diff view" })

-- Diff the whole branch against its merge-base with the default branch (GitHub PR view).
-- Resolves the base from origin/HEAD, falling back to common names, so it works
-- whether the main line is master, main, macos, etc.
map({ "n", "v" }, "<Leader><Leader>G", function()
	local dir = vim.fn.expand("%:p:h")
	local function git(...)
		local out = vim.fn.system({ "git", "-C", dir, ... })
		return vim.v.shell_error == 0 and vim.trim(out) or nil
	end
	local base
	local default = git("symbolic-ref", "--short", "refs/remotes/origin/HEAD")
	for _, ref in ipairs({ default, "origin/master", "origin/main", "master", "main" }) do
		if ref and ref ~= "" and git("rev-parse", "--verify", "--quiet", ref) then
			base = ref
			break
		end
	end
	if not base then
		vim.notify("diffview: no base branch found (origin default / master / main)", vim.log.levels.ERROR)
		return
	end
	-- A...B uses the merge-base of A and B as the diff base.
	vim.cmd("DiffviewOpen " .. base .. "...HEAD")
end, { desc = "Diff branch vs merge-base (PR view)" })
map({ "n", "v" }, "<Leader>gh", ":DiffviewFileHistory %<CR>", { desc = "Open file history for current file" })
map({ "n", "v" }, "<Leader>gH", ":DiffviewFileHistory<CR>", { desc = "Open file history for current branch" })

-- Window Navigation
-- map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
-- map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
-- map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
-- map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Window Resizing
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Tab Management
map("n", "<leader><tab>H", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab>L", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>t", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Quickfix List

-- local function toggle_qf()
-- 	for _, win in ipairs(vim.fn.getwininfo()) do
-- 		if win.quickfix == 1 then
-- 			vim.cmd("cclose")
-- 			return
-- 		end
-- 	end
-- 	vim.cmd("copen")
-- end
local function toggle_qf()
	local qf_winid = nil
	local cur_win = vim.api.nvim_get_current_win()

	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			qf_winid = win.winid
			break
		end
	end

	if qf_winid then
		if qf_winid == cur_win then
			-- Already focused → close it
			vim.cmd("cclose")
		else
			-- Open but not focused → jump to it
			vim.api.nvim_set_current_win(qf_winid)
		end
	else
		-- Not open → open it
		vim.cmd("copen")
	end
end

map("n", "<leader>mm", ":make<cr>", { noremap = true, silent = true, desc = "Run make" })

map("n", "<leader>l", toggle_qf, { noremap = true, silent = true, desc = "Open Quickfix list" })
map("n", "<leader>L", "<cmd>Telescope quickfixhistory<cr>", { noremap = true, silent = true, desc = "Quickfix history" })
map("n", "]l", ":cnewer | copen<cr>", { noremap = true, silent = true, desc = "Next Quickfix history" })
map("n", "[l", ":colder | copen<cr>", { noremap = true, silent = true, desc = "Previous Quickfix history" })
