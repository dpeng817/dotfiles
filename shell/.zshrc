. "$HOME/.local/bin/env"

########################################################
# vi mode
########################################################
# Enable vi mode
bindkey -v

# Reduce key delay
export KEYTIMEOUT=1

# Basic history navigation in vi mode
bindkey -M vicmd 'k' up-line-or-history
bindkey -M vicmd 'j' down-line-or-history
bindkey '^R' history-incremental-search-backward

########################################################
# aliases
########################################################
alias reload='source $HOME/.local/bin/env && source ~/.zshrc'
# load the uv env in the current directory
alias uve='source .venv/bin/activate'

########################################################
# nvm
########################################################
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

########################################################
# settings
########################################################
# set the default editor to cursor
export EDITOR=cursor

# turn off auto-update on homebrew
export HOMEBREW_NO_AUTO_UPDATE=1

########################################################
# cursor
########################################################
# set the default editor to cursor
export EDITOR=cursor


