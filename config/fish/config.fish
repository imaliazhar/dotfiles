if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g fish_greeting

    # Abbreviations
    # --------------------------------------------------------------------------
    abbr --add g git
    abbr --add gco git checkout
    abbr --add gcb git checkout -b
    abbr --add gs git status -sb
    abbr --add gcan git commit --amend --no-edit
    abbr --add ls eza
    abbr --add venv source .venv/bin/activate.fish
    abbr --add y yarn
    abbr --add lf yazi
    abbr --add t select-tmux-session

    abbr --add ga git add
    abbr --add gc git commit -m
    abbr --add gl git "log --pretty=format:'%C(yellow)%h%Creset %C(white)%s %C(dim #6e738d)%an %ar %Creset' --date=format:\"%b %d, '%y\""
    abbr --add gac git commit -am
    abbr --add gbr git branch
    abbr --add gpop git stash pop
    abbr --add gch git cherry-pick -e
    abbr --add gdc git reset HEAD^
    abbr --add gdd git reset --hard HEAD
    abbr --add grs git checkout --
    abbr --add gdelete git reset --hard HEAD~
    abbr --add gra git commit --amend --no-edit
    abbr --add grc git rebase --continue
    abbr --add gignore git update-index --skip-worktree
    abbr --add gunignore git update-index --no-skip-worktree

    abbr --add gg lazygit

    # Shell plugins
    # --------------------------------------------------------------------------

    # Zoxide
    zoxide init fish | source

    # Atuin
    set -gx ATUIN_NOBIND true
    atuin init fish | source

    # bind to ctrl-r in normal and insert mode, add any other bindings you want here too
    bind \cr _atuin_search
    bind -M insert \cr _atuin_search

    # Notifications
    source ~/.config/fish/functions/notify_command_completion.fish

end
