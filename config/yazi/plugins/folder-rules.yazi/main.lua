local function has_git(cwd)
	local git = tostring(cwd) .. "/.git"
	-- `.git` is a directory in a normal repo (probe via HEAD) and a regular
	-- file inside a worktree — fall back so both cases are detected.
	local f = io.open(git .. "/HEAD", "r") or io.open(git, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local function setup()
	ps.sub("cd", function()
		local cwd = cx.active.current.cwd

		-- Sort files in Downloads
		if cwd:ends_with("Downloads") then
			ya.emit("sort", { "mtime", reverse = true, dir_first = false })
		end

		-- Reveal dotfiles when sitting at the root of a git repo
		if has_git(cwd) then
			ya.emit("hidden", { "show" })
		else
			ya.emit("hidden", { "hide" })
		end
	end)
end

return { setup = setup }
