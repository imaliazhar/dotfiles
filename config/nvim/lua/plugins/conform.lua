return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters = {
				eslint_d_fix = {
					command = "eslint_d",
					args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
					stdin = true,
					cwd = require("conform.util").root_file({ "eslint.config.mjs", "package.json" }),
					require_cwd = true,
				},
			},
			formatters_by_ft = {
				fish = { "fish_indent" },
				lua = { "stylua" },
				python = { "python" },
				rust = { "rustfmt", lsp_format = "fallback" },
				javascript = { "eslint_d_fix", "prettier" },
				javascriptreact = { "eslint_d_fix", "prettier" },
				typescript = { "eslint_d_fix", "prettier" },
				typescriptreact = { "eslint_d_fix", "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				xml = { "xmlformatter" },
				sql = { "sleek" },
				toml = { "taplo" },
			},
			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		})

		vim.keymap.set("n", "<leader>F", function()
			conform.format({ async = true, lsp_fallback = true })
		end)
	end,
}
