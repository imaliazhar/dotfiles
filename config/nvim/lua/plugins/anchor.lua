return {
	"imAliAzhar/anchor.nvim",
	config = function()
		require("anchor").setup(nil, {
			keymaps = {
				activate = "'",
				-- hide = "q",
				-- focus_next = "j",
				-- focus_previous = "k",
				-- confirm = "<esc>",
			},
		})
	end,
}
