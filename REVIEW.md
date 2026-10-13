# Dotfiles review

Good patterns already in place: `config/aerospace/monitor` (a script that builds a gitignored config from tracked pieces) and `tmux-leap` (which has its own tests).

Recommended order: #4 (the password) right away, then #1 (Brewfile).

## 1. Bootstrap: two lists of packages

`scripts/bootstrap.sh` handles about eight separate jobs, and its package list overlaps with another file:

- **Package lists.** The packages to install are listed inside `main()`, but there's also an untracked `Brewfile`. That's two lists that will drift apart. Arc, Alfred, ChatGPT, ProtonVPN, qBittorrent, WhatsApp, WezTerm, Karabiner, Hammerspoon and IINA are all Homebrew casks. If they move into the Brewfile and bootstrap runs `brew bundle`, about 200 lines of DMG, zip and GitHub-release installer code can be deleted. Removing that code loses nothing, which means it isn't doing useful work.

## 2. Shell configs: fish is the default, but zsh and nushell are still around

Fish is the default shell, but `config/zsh` (32 files) and `config/nushell` (681-line `config.nu`) are still tracked and have gone stale:

- `exports.zsh` hardcodes `PNPM_HOME=/Users/imaliazhar/...` (an old username) and a fixed `fnm_multishells/33506_…` path.
- It still sets `MYVIMRC=…/init.vim`, though the nvim config uses `init.lua`.
- It loads both nvm and fnm.
- It puts postgres@16 on the PATH, while fish uses @17.
- `.zshrc` has the same pipx PATH line twice.
- Shortcuts have drifted between the shells. `gcb` means `git checkout -b` in fish but copies the branch name in zsh. Inside `fish/config.fish`, `t` is defined twice (the second definition wins) and `gcan` is defined twice.

Treat fish as the only interactive shell. Cut zsh down to the minimal environment that non-interactive tools need, and delete nushell unless it's actually used.

The work-only setup is chosen by `scutil --get ComputerName = Omio-C933BE43`. Since there are real work and personal variants, move it into its own file (`conf.d/work.fish`, or a gitignored `local.fish` like the existing secrets file) instead of keeping it inline in `config.fish`.

## 3. It isn't clear which files the repo actually manages

All of `config/` is symlinked to `~/.config`, and the `.gitignore` there lists only what to exclude. As a result, every app that writes to `~/.config` shows up as untracked: butler, ghpr, gws, pi, pr-sentinel, uv and zellij all appear in `git status`. `bin/` does the opposite: it lists only what to include. It also holds a 120 MB `plannotator` binary, the `uv` binaries and symlinks into other projects.

Making `config/` include-only too (`/*`, then `!/nvim/`, `!/fish/`, …) would make the managed set explicit and stop new apps from cluttering `git status`.

## 4. Security and cleanup

- **`cmds.txt` contains a plaintext admin password.** It's untracked, but bootstrap pulls from a public GitHub repo, so a `git add .` would publish it. Delete the file.
- `scripts/jira-branch-sync.ts` hardcodes the work email and Jira cloud ID in that same public repo. Reading them from the environment would be safer.
- `nvim/**/disabled/` holds 8 dead files, and git history already keeps them, so they can go.

## Done

- **Symlinks.** All links are listed in `links.conf` and created by `scripts/setup-symlinks.sh`. Running it again changes nothing, whatever is at a destination is replaced, and launch agents are reloaded when their link changes. Bootstrap calls it; `setup_alfred`, `ensure_symlink` and `launchd/load.sh` are gone.
- **Theme switcher.** `theme` (in `~/.local/bin`, from `config/theme/theme`) links `config/theme/$NAME/$app/$MODE` to a gitignored `theme.*` file that each app includes, so switching no longer edits tracked files and there are no markers. Themes are read from the directory names, `theme` with no arguments picks with fzf, and `theme dark|light` keeps the current theme. Running nvims reload over their sockets instead of `tmux send-keys`. Hammerspoon now only switches the mode, so it keeps whichever theme was picked.
