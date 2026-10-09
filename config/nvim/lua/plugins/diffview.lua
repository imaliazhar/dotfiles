return {
	"sindrets/diffview.nvim",
	dependencies = { "lewis6991/gitsigns.nvim" },
	config = function()
		local actions = require("diffview.actions")

		-- File panel layout. float = 1 shows the file list as a centered floating
		-- window; otherwise side = 1 docks it on the left (else bottom). Hoisted here
		-- so the file-panel keymaps below can adapt their behavior to the layout.
		local float = 1
		local side = 1

		local function select_entry_if_file()
			local view = require("diffview.lib").get_current_view()

			if view and view:infer_cur_file(false) then
				actions.select_entry()
			end
		end

		local function focus_entry_if_file()
			local view = require("diffview.lib").get_current_view()

			if view and view:infer_cur_file(false) then
				actions.focus_entry()
			end
		end

		local function focus_main_diff()
			local view = require("diffview.lib").get_current_view()
			if not view or not view.cur_layout then
				return
			end

			local main_win = view.cur_layout:get_main_win()
			if main_win then
				main_win:focus()
			end
		end

		local function jump_to_first_change(view)
			vim.schedule(function()
				if not view or view.closing:check() or not view.cur_layout then
					return
				end

				local main_win = view.cur_layout:get_main_win()
				if not main_win or not main_win.id or not vim.api.nvim_win_is_valid(main_win.id) then
					return
				end

				vim.api.nvim_win_call(main_win.id, function()
					vim.cmd("normal! gg0")

					if vim.fn.diff_hlID(vim.fn.line("."), 1) == 0 then
						vim.cmd("silent! normal! ]c")
					end

					vim.cmd("normal! zz")
				end)

				view.cur_layout:sync_scroll()
			end)
		end

		actions.x_toggle_files_focus = function()
			local view = require("diffview.lib").get_current_view()
			if not view then
				return
			end

			if view.panel and view.panel:is_focused() then
				focus_main_diff()
				-- When the panel floats it overlaps the diff, so hide it once
				-- focus moves away. The next toggle re-opens it via focus_files.
				if float == 1 then
					actions.toggle_files()
				end
			else
				actions.focus_files()
			end
		end

		actions.x_select_entry = function()
			actions.select_next_entry()
			actions.toggle_files()
		end

		actions.x_select_next_entry = function()
			actions.next_entry()
			select_entry_if_file()
		end

		actions.x_select_prev_entry = function()
			actions.prev_entry()
			select_entry_if_file()
		end

		actions.x_quit = function()
			vim.cmd("DiffviewClose")
		end

		actions.x_goto_file_edit = function()
			actions.goto_file_edit()
			vim.cmd("DiffviewClose")
		end

		actions.x_goto_file_edit_first_tab = function()
			local view = require("diffview.lib").get_current_view()
			if not view then
				return
			end

			local file = view:infer_cur_file(false)
			if not file or not file.absolute_path then
				return
			end

			if vim.fn.filereadable(file.absolute_path) == 0 then
				vim.notify("File does not exist on disk: " .. file.absolute_path, vim.log.levels.ERROR)
				return
			end

			local cursor
			if file == view.cur_entry and view.cur_layout then
				local main_win = view.cur_layout:get_main_win()
				if main_win and main_win.id and vim.api.nvim_win_is_valid(main_win.id) then
					cursor = vim.api.nvim_win_get_cursor(main_win.id)
				end
			end

			local first_tab = vim.api.nvim_list_tabpages()[1]
			if not first_tab then
				return
			end

			vim.api.nvim_set_current_tabpage(first_tab)
			if file.layout then
				file.layout:restore_winopts()
			end
			vim.cmd("edit " .. vim.fn.fnameescape(file.absolute_path))

			if cursor then
				pcall(vim.api.nvim_win_set_cursor, 0, cursor)
			end
		end

		-- Open the entry under the cursor, focus its diff, and dismiss the file
		-- panel. Used for <cr>/l when the panel floats.
		actions.x_focus_entry_and_close = function()
			local view = require("diffview.lib").get_current_view()
			if not (view and view:infer_cur_file(false)) then
				return
			end
			actions.focus_entry()
			actions.toggle_files()
		end

		-- File-panel navigation adapts to the layout:
		--  * float: j/k only move the cursor (no auto-open); <cr>/l open the diff,
		--    focus it, and close the floating panel.
		--  * docked: j/k move and open the diff as you go; <cr>/l just focus it.
		local nav_next, nav_prev, open_entry
		if float == 1 then
			nav_next = actions.next_entry
			nav_prev = actions.prev_entry
			open_entry = actions.x_focus_entry_and_close
		else
			nav_next = actions.x_select_next_entry
			nav_prev = actions.x_select_prev_entry
			open_entry = focus_entry_if_file
		end

		require("diffview").setup({
			enhanced_diff_hl = true,
			use_icons = false,
			signs = {
				fold_closed = " ",
				fold_open = " ",
				done = "✓ ",
			},
			default = {
				winbar_info = true, -- See |diffview-config-view.x.winbar_info|
			},
			keymaps = {

				disable_defaults = false,

				view = {
					{ "n", "q", actions.x_quit, { desc = "Close diff view" } },
					{
						"n",
						"<leader>e",
						actions.x_toggle_files_focus,
						{ desc = "Toggle focus between file panel and diff" },
					},
					{
						"n",
						"<leader>E",
						actions.x_goto_file_edit_first_tab,
						{ desc = "Edit file in first tab at diff cursor" },
					},
					{
						"n",
						"<leader><leader>e",
						actions.x_goto_file_edit_first_tab,
						{ desc = "Edit file in first tab at diff cursor" },
					},
				},
				file_panel = {
					{ "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
					{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },

					{ "n", "j", nav_next, { desc = "Next file" } },
					{ "n", "k", nav_prev, { desc = "Previous file" } },
					{ "n", "l", open_entry, { desc = "Open & focus the diff" } },
					{ "n", "<cr>", open_entry, { desc = "Open & focus the diff" } },
					{ "n", "L", actions.x_goto_file_edit, { desc = "Edit file in previous tab and close Diffview" } },
					{ "n", "e", actions.x_goto_file_edit, { desc = "Edit file in previous tab and close Diffview" } },
					{
						"n",
						"<leader>E",
						actions.x_goto_file_edit_first_tab,
						{ desc = "Edit file in first tab at diff cursor" },
					},
					{
						"n",
						"<leader><leader>e",
						actions.x_goto_file_edit_first_tab,
						{ desc = "Edit file in first tab at diff cursor" },
					},

					{
						"n",
						"<leader>e",
						actions.x_toggle_files_focus,
						{ desc = "Toggle focus between file panel and diff" },
					},
					{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel." } },

					{ "n", "<space>", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
					{ "n", "a", actions.stage_all, { desc = "Stage all entries" } },
					{ "n", "u", actions.unstage_all, { desc = "Unstage all entries" } },
					{ "n", "r", actions.restore_entry, { desc = "Restore entry to the state on the left side" } },

					{ "n", "zo", actions.open_fold, { desc = "Expand fold" } },
					{ "n", "zc", actions.close_fold, { desc = "Collapse fold" } },
					{ "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
					{ "n", "Z", actions.open_all_folds, { desc = "Expand all folds" } },
					{ "n", "zz", actions.close_all_folds, { desc = "Collapse all folds" } },

					{ "n", "q", actions.x_quit, { desc = "Close diff view" } },
				},
			},

			file_panel = {
				listing_style = "list",
				win_config = function()
					local editor_width = vim.o.columns
					local editor_height = vim.o.lines

					if float ~= 1 then
						if side == 1 then
							return { position = "left", width = math.floor(editor_width * 0.15) }
						end

						return { position = "bottom", height = math.floor(editor_height * 0.3) }
					end

					local c = { type = "float" }
					c.width = math.min(100, editor_width)
					c.height = math.min(24, editor_height)
					c.col = math.floor(editor_width * 0.5 - c.width * 0.5)
					c.row = math.floor(editor_height * 0.5 - c.height * 0.5)
					return c
				end,
			},

			hooks = {
				view_opened = function(view)
					-- actions.toggle_files()
					actions.open_all_folds()
					view.emitter:on("file_open_post", function()
						jump_to_first_change(view)
					end)
				end,

				diff_buf_win_enter = function(_, winid)
					vim.wo[winid].wrap = false
					vim.wo[winid].foldenable = false
				end,

				view_leave = function(view)
					if view.closing:check() then
						return
					end

					vim.schedule(function()
						if
							view.tabpage
							and vim.api.nvim_tabpage_is_valid(view.tabpage)
							and not view.closing:check()
						then
							view:close()
							require("diffview.lib").dispose_view(view)
						end
					end)
				end,
			},
		})
	end,
}
