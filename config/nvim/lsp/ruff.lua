---@type vim.lsp.Config
return {
	cmd = { "uv", "run", "ruff", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "ruff.toml" },
}
