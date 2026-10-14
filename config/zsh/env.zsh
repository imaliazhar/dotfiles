# Environment shared by every shell. Sourced from .zprofile; fish inherits it
# via exec from .zshrc, so nothing here should be set again in fish.
# Prepends run lowest-priority first, so the final PATH reads top to bottom.

typeset -U path

[[ $(scutil --get ComputerName 2>/dev/null) == Omio-C933BE43 ]] && work_machine=1


# General
# ------------------------------------------------------------------------------

export EDITOR="nvim"


# CLI tools
# ------------------------------------------------------------------------------

# FZF
export FZF_DEFAULT_OPTS='--bind=ctrl-j:accept --ansi --header= --padding=5% --prompt='"'"'  '"'"'$'"'"' '"'"' --pointer=▸ --color=pointer:bright-yellow,gutter:-1,bg+:-1,fg+:bright-yellow:bold --gutter='"'"' '"'"''

# Lazygit
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme.yml"

# Pi
export PI_SKIP_VERSION_CHECK=1
export PI_OFFLINE=1


# SDKs and toolchains
# ------------------------------------------------------------------------------

# Node
if command -v fnm >/dev/null; then
  eval "$(fnm env --shell zsh)"
fi

# Ruby
if [[ -n $work_machine ]]; then
  source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
  chruby ruby-3.3.5
fi

# Maestro
if [[ -n $work_machine ]]; then
  export MAESTRO_CLI_AI_MODEL=gpt-4.1
  export MAESTRO_DRIVER_STARTUP_TIMEOUT=30000
  path=("$HOME/.maestro/bin" $path)
fi

# Android SDK / Java
if [[ -n $work_machine ]]; then
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  path=("$ANDROID_HOME/platform-tools" "$ANDROID_HOME/emulator" $path)
fi

# Rust
path=("$HOME/.cargo/bin" $path)

# Google Cloud SDK
if [[ -n $work_machine ]]; then
  export CLOUDSDK_PYTHON=/opt/homebrew/bin/python3.13
  path=(/opt/homebrew/share/google-cloud-sdk/bin $path)
fi

# PostgreSQL
if [[ -n $work_machine ]]; then
  path=(/opt/homebrew/opt/postgresql@17/bin $path)
fi

unset work_machine


# PATH overrides
# ------------------------------------------------------------------------------

path=("$HOME/.local/bin" "$HOME/.config/emacs/bin" $path)


# Secrets
# ------------------------------------------------------------------------------

[[ -f $ZDOTDIR/secrets.zsh ]] && source $ZDOTDIR/secrets.zsh
