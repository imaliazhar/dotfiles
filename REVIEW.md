# Dotfiles review

Good patterns already in place: `config/aerospace/monitor` (a script that builds a gitignored config from tracked pieces) and `tmux-leap` (which has its own tests).

## 1. Bootstrap: two lists of packages

`scripts/bootstrap.sh` handles about eight separate jobs, and its package list overlaps with another file:

- **Package lists.** The packages to install are listed inside `main()`, but there's also an untracked `Brewfile`. That's two lists that will drift apart. Arc, Alfred, ChatGPT, ProtonVPN, qBittorrent, WhatsApp, WezTerm, Karabiner, Hammerspoon and IINA are all Homebrew casks. If they move into the Brewfile and bootstrap runs `brew bundle`, about 200 lines of DMG, zip and GitHub-release installer code can be deleted. Removing that code loses nothing, which means it isn't doing useful work.

## 2. Shell configs

The work-only setup is chosen by `scutil --get ComputerName = Omio-C933BE43` inline in `config/zsh/env.zsh`. Since there are real work and personal variants, it could move into its own file (a gitignored `local.zsh` like the existing secrets file).

## Done

- **Symlinks.** All links are listed in `links.conf` and created by `scripts/setup-symlinks.sh`. Running it again changes nothing, whatever is at a destination is replaced, and launch agents are reloaded when their link changes. Bootstrap calls it; `setup_alfred`, `ensure_symlink` and `launchd/load.sh` are gone.
- **Theme switcher.** `theme` (in `~/.local/bin`, from `config/theme/theme`) links `config/theme/$NAME/$app/$MODE` to a gitignored `theme.*` file that each app includes, so switching no longer edits tracked files and there are no markers. Themes are read from the directory names, `theme` with no arguments picks with fzf, and `theme dark|light` keeps the current theme. Running nvims reload over their sockets instead of `tmux send-keys`. Hammerspoon now only switches the mode, so it keeps whichever theme was picked.
- **Login shell.** zsh owns the environment as the login shell and hands interactive terminals to fish; bootstrap sets zsh as the default shell.
- **`config/` allowlist.** `.gitignore` ignores `config/*` and lists the tracked apps, so new tools' state stays out of `git status`.
- **Dead config.** nushell, alacritty, zellij, unlinked app configs (code, firefox, obsidian, sidebery, youtube-dl), unused Karabiner rules, `nvim/**/disabled/`, `jira-branch-sync.ts`, the stale session pickers and WezTerm's tmux emulation are deleted.
