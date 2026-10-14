# Hand interactive terminals to fish; agents, scripts and `zsh` typed from fish stay in zsh.
if [[ -o interactive && -t 0 && -t 1 && -z $NO_FISH && -z $CLAUDECODE \
      && $(ps -o comm= -p $PPID) != *fish* ]] && command -v fish >/dev/null; then
  unset OLDPWD
  SHELL=$(command -v fish) exec fish
fi
