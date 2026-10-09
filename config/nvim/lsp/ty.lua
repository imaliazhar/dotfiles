---@type vim.lsp.Config
return {
	cmd = { "uv", "run", "ty", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml" },
}
