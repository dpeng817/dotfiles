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
# Bind delete key in vi mode
bindkey "^[[3~" delete-char
bindkey -M vicmd "^[[3~" delete-char
bindkey -M viins "^[[3~" delete-char
bindkey -M viins "^?" backward-delete-char

########################################################
# aliases
########################################################
alias reload='source $HOME/.local/bin/env && source ~/.zshrc'
# load the uv env in the current directory
alias uve='source .venv/bin/activate'
alias rootenv='pushd ~ && uve && popd'
# stoppls
alias bg_stoppls='nohup python -m stoppls.cli run > stoppls.log 2>&1 & '
alias stp='rootenv && bg_stoppls'
# edit specific files
alias ez='vim $HOME/.zshrc'
alias ed='vim $HOME/agent_context/DEVELOPMENT_STANDARDS.md'
alias ep='vim $HOME/agent_context/languages/python.md'
alias ev='vim $HOME/.vimrc'

########################################################
# nvm
########################################################
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

########################################################
# python
########################################################
# by default, use uv venv in the home directory
pushd $HOME && uve && popd

########################################################
# secrets
########################################################
export $(cat $HOME/.config/.env | xargs)

########################################################
# settings
########################################################
# set the default editor to vim
export EDITOR=vim

# turn off auto-update on homebrew
export HOMEBREW_NO_AUTO_UPDATE=1

# make tab accept autocomplete
bindkey '^F' autosuggest-accept
########################################################
# activations
########################################################

# activate mine
eval "$(/Users/christopherdecarolis/.local/bin/mise activate zsh)"

# activate zsh autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh



