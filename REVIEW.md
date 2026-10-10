# Dotfiles review

Good patterns already in place: `aerospace-monitor-toggle.sh` (a script that builds a gitignored config from tracked pieces) and `tmux-leap` (which has its own tests).

Recommended order: #5 (the password) right away, then #2 (stops theme switches dirtying git), then #1 (Brewfile).

## 1. Bootstrap: two lists of packages

`scripts/bootstrap.sh` handles about eight separate jobs, and its package list overlaps with another file:

- **Package lists.** The packages to install are listed inside `main()`, but there's also an untracked `Brewfile`. That's two lists that will drift apart. Arc, Alfred, ChatGPT, ProtonVPN, qBittorrent, WhatsApp, WezTerm, Karabiner, Hammerspoon and IINA are all Homebrew casks. If they move into the Brewfile and bootstrap runs `brew bundle`, about 200 lines of DMG, zip and GitHub-release installer code can be deleted. Removing that code loses nothing, which means it isn't doing useful work.

## 2. Theme switcher: three ways of applying a theme, two of which edit tracked files

The per-app scripts in `config/theme/scripts/` each work differently:

| App | How the theme is applied |
|---|---|
| lazygit, yazi | Symlink to the theme file |
| wezterm, nvim `theme.lua` | Overwrite a file |
| tmux, nvim lualine | Cut the tracked `tmux.conf` / `lualine.lua` at a `>>> THEME MARKER <<<` line and append the theme |

The third method causes two problems:

- Every theme switch changes tracked files, so `git status` is dirty after each switch.
- Nothing enforces the marker. An edit to `tmux.conf` below line 150 is silently deleted by the next switch.

**Fix:** have every app include a generated, gitignored theme file (for example `source-file ~/.config/tmux/theme.tmux` in tmux, and a `require` in lualine). Then every per-app script does the same thing: link `$THEME/$app/$MODE` to `$app/theme.*`. That's one function plus a list of apps.

Two smaller fixes in the same area:

- `set-theme.sh` hardcodes `^(cattpuccin|rose-pine)$`. It could read the list from the directory names instead.
- Reloading nvim with `tmux send-keys "  rt"` breaks if the pane is in insert mode or the mapping changes. `nvim --server … --remote-send` (or `bin/nvr`) is more reliable.

## 3. Shell configs: fish is the default, but zsh and nushell are still around

Fish is the default shell, but `config/zsh` (32 files) and `config/nushell` (681-line `config.nu`) are still tracked and have gone stale:

- `exports.zsh` hardcodes `PNPM_HOME=/Users/imaliazhar/...` (an old username) and a fixed `fnm_multishells/33506_…` path.
- It still sets `MYVIMRC=…/init.vim`, though the nvim config uses `init.lua`.
- It loads both nvm and fnm.
- It puts postgres@16 on the PATH, while fish uses @17.
- `.zshrc` has the same pipx PATH line twice.
- Shortcuts have drifted between the shells. `gcb` means `git checkout -b` in fish but copies the branch name in zsh. Inside `fish/config.fish`, `t` is defined twice (the second definition wins) and `gcan` is defined twice.

Treat fish as the only interactive shell. Cut zsh down to the minimal environment that non-interactive tools need, and delete nushell unless it's actually used.

The work-only setup is chosen by `scutil --get ComputerName = Omio-C933BE43`. Since there are real work and personal variants, move it into its own file (`conf.d/work.fish`, or a gitignored `local.fish` like the existing secrets file) instead of keeping it inline in `config.fish`.

## 4. It isn't clear which files the repo actually manages

All of `config/` is symlinked to `~/.config`, and the `.gitignore` there lists only what to exclude. As a result, every app that writes to `~/.config` shows up as untracked: butler, ghpr, gws, pi, pr-sentinel, uv and zellij all appear in `git status`. `bin/` does the opposite: it lists only what to include. It also holds a 120 MB `plannotator` binary, the `uv` binaries and symlinks into other projects.

Making `config/` include-only too (`/*`, then `!/nvim/`, `!/fish/`, …) would make the managed set explicit and stop new apps from cluttering `git status`.

## 5. Security and cleanup

- **`cmds.txt` contains a plaintext admin password.** It's untracked, but bootstrap pulls from a public GitHub repo, so a `git add .` would publish it. Delete the file.
- `scripts/jira-branch-sync.ts` hardcodes the work email and Jira cloud ID in that same public repo. Reading them from the environment would be safer.
- `nvim/**/disabled/` holds 8 dead files, and git history already keeps them, so they can go.

## Done

- **Symlinks.** All links are listed in `links.conf` and created by `scripts/setup-symlinks.sh`. Running it again changes nothing, whatever is at a destination is replaced, and launch agents are reloaded when their link changes. Bootstrap calls it; `setup_alfred`, `ensure_symlink` and `launchd/load.sh` are gone.
