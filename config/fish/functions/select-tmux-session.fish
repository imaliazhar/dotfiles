function select-tmux-session --description 'FZF-based tmux session picker'
    if test "$MUX" != tmux
        return 0
    end

    # Fish does not support associative arrays, so we use parallel arrays instead.
    set session_names_list
    set session_dirs_list
    set active_status_list

    # Get a list of existing tmux sessions, sorted by last attached time.
    # stderr is silenced: with no tmux server running there are simply no sessions yet.
    for line in (tmux list-sessions -F '#{?session_last_attached,#{session_last_attached},0} #{session_name} #{pane_start_path}' 2>/dev/null | sort -nr)
        # @fish-lsp-disable-next-line 4004 
        echo $line | read -l _timestamp session_name session_dir
        if string match -q '_*' -- $session_name
            continue
        end
        set -a session_names_list $session_name
        set -a session_dirs_list $session_dir
        set -a active_status_list true
    end

    set misc_sessions home dotfiles homelab obsidian
    set misc_session_dirs_list $HOME $HOME/Dotfiles $HOME/Homelab "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Gringotts"
    #
    for i in (seq (count $misc_sessions))
        if contains $misc_sessions[$i] $session_names_list
            continue
        end

        set -a session_names_list $misc_sessions[$i]
        set -a session_dirs_list $misc_session_dirs_list[$i]
        set -a active_status_list false
    end

    for dir in ~/Projects/*
        if not test -d $dir
            continue
        end

        set session_name (string replace -a '.' '_' (basename $dir))

        if contains $session_name $session_names_list
            continue
        end

        set -a session_names_list $session_name
        set -a session_dirs_list $dir
        set -a active_status_list false
    end

    set formatted_session_list

    set green (set_color green)
    set nc (set_color normal)

    for i in (seq (count $session_names_list))
        if test $active_status_list[$i] = true
            set display "$green• $session_names_list[$i]$nc"
        else
            set display "  $session_names_list[$i]"
        end

        # Stash the session dir (home abbreviated to ~) as a hidden second field
        # (tab-delimited) so a key binding can copy it. --with-nth 1 keeps it off-screen.
        set -a formatted_session_list (printf '%s\t%s' $display (string replace -- $HOME '~' $session_dirs_list[$i]))
    end

    # ctrl-y copies the project path of the row under the cursor. {2} is the hidden
    # dir field — execute placeholders read the original line, so it works despite
    # --with-nth 1 hiding the field from the display/search.
    set selected_line (printf "%s\n" $formatted_session_list | fzf --no-info --no-scrollbar \
        --delimiter \t --with-nth 1 \
        --bind 'ctrl-y:execute-silent(printf %s {2} | pbcopy)+abort')

    if test -z "$selected_line"
        return
    end

    # fzf returns the whole tab-delimited line; keep only the visible name field,
    # then strip the leading "• " or two-space formatting prefix.
    set selected_session (string sub -s 3 (echo $selected_line | cut -f1))

    set selected_idx (contains -i $selected_session $session_names_list)

    if not test "$active_status_list[$selected_idx]" = true
        cd $session_dirs_list[$selected_idx]

        set tmux_args -d -s $selected_session -n $EDITOR

        tmux new-session $tmux_args

        if test "$selected_session" = home
            tmux rename-window -t $selected_session:1 agent
            tmux send-keys -t $selected_session:1.1 claude Enter
        else
            tmux send-keys -t $selected_session:1.1 $EDITOR Enter
            tmux new-window -d -t $selected_session:2 -n claude
            tmux send-keys -t $selected_session:2.1 claude Enter
        end
    end

    if tmux list-windows -t "=$selected_session" -F '#{window_index}' | string match -q 2
        tmux select-window -t "=$selected_session:2"
    end

    if test -z "$TMUX"
        tmux attach -t $selected_session
    else
        tmux switch-client -t $selected_session
    end
end
