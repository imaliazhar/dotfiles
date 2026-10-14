if command -q fnm
    set -l inherited $FNM_MULTISHELL_PATH/bin
    fnm env --use-on-cd --shell fish | source

    # Give this shell its own multishell, kept at the PATH slot zsh put node in
    if set -l i (contains -i -- $inherited $PATH[2..])
        set PATH[(math $i + 1)] $PATH[1]
        set -e PATH[1]
    end
end
