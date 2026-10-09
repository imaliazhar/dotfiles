return {
	"dmtrKovalenko/fff.nvim",
	-- Build only the Neovim cdylib. Building the whole workspace also builds
	-- fff-mcp, whose default `zlob` feature requires Zig.
	build = "cargo build --release -p fff-nvim",
	opts = {
		preview = {
			enabled = false,
		},
	},
	keys = {
		{
			"<leader><c-f>", -- try it if you didn't it is a banger keybinding for a picker
			function()
				require("fff").find_files({
					preview = {
						enabled = false,
					},
				})
			end,
			desc = "Toggle FFF",
		},
	},
}
