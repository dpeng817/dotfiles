autoload -Uz compinit
compinit -i
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
# export everything
set -a


# Auto-enter tmux
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Auto-start tmux
# if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#     tmux attach-session -t default || tmux new-session -s default
# fi
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
alias ct='npx @mariozechner/claude-trace --include-all-requests'
alias xv6='cd ~/xv6-public && ./run-xv6.sh qemu-nox'
alias xv6-rebuild='cd ~/xv6-public && ./run-xv6.sh rebuild && ./run-xv6.sh qemu-nox'
alias ws='workstack'
alias pd='git fetch && git checkout '
alias gd='git diff $(git merge-base HEAD origin/master)..HEAD'
alias reload='source $HOME/.local/bin/env && source ~/.zshrc'
# load the uv env in the current directory
alias uve='source .venv/bin/activate'
alias rootenv='(cd $HOME && source .venv/bin/activate)'
# stoppls
alias bg_stoppls='nohup python -m stoppls.cli run > stoppls.log 2>&1 & '
alias stp='rootenv && bg_stoppls'
# edit specific files
alias ez='vim $HOME/.zshrc'
alias ed='vim $HOME/agent_context/DEVELOPMENT_STANDARDS.md'
alias ep='vim $HOME/agent_context/languages/python.md'
alias ev='vim $HOME/.vimrc'
alias es='vim $HOME/.config/.env'
alias gr='gt'
# alias dev='$HOME/.dpeng/exp-manager.sh'
alias cl='claude --dangerously-skip-permissions'
alias uvi="source $HOME/indent/.venv/bin/activate"
# indent directories
alias i='cd $HOME/indent'
alias i1='cd $HOME/indent1'
alias i2='cd $HOME/indent2'
alias i3='cd $HOME/indent3'


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
[ -f "$HOME/.venv/bin/activate" ] && rootenv
########################################################
# secrets
########################################################
[ -f "$HOME/.config/.env" ] && source $HOME/.config/.env

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

# activate mise
[ -x "$HOME/.local/bin/mise" ] && eval "$("$HOME/.local/bin/mise" activate zsh)"

# activate zsh autosuggestions
for _f in \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  [ -f "$_f" ] && source "$_f" && break
done
unset _f




[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

indent-dev-key() {
  local copy
  if command -v pbcopy >/dev/null; then copy=pbcopy
  elif command -v xclip >/dev/null; then copy="xclip -selection clipboard"
  else echo "no clipboard command available" >&2; return 1
  fi
  jq -r '.extra_exponent_api_keys.development' ~/.config/indent/config.json | eval "$copy"
    echo "Development key copied to clipboard"
}

# Workstack completion
command -v workstack >/dev/null && source <(workstack completion zsh)

# Workstack shell integration for zsh
# This function wraps the workstack CLI to provide seamless worktree switching

workstack() {
  # Don't intercept if we're doing shell completion
  if [ -n "$_WORKSTACK_COMPLETE" ]; then
    command workstack "$@"
  elif [ "$1" = "switch" ]; then
    # Check if __switch returns the passthrough marker
    shift
    local output
    output=$(command workstack __switch "$@")
    if [ "$output" = "__WORKSTACK_PASSTHROUGH__" ]; then
      # Pass through to regular command
      command workstack switch "$@"
    else
      # Eval the activation script
      eval "$output"
    fi
  else
    # Pass through all other commands
    command workstack "$@"
  fi
}

# Switch a branch from worktree to main directory for testing
wsp() {
    if [ -z "$1" ]; then
        echo "Usage: wsp <branch_name>"
        return 1
    fi

    local branch_name="$1"
    local main_dir="$PWD"

    echo "Detaching worktree $branch_name"
    (workstack switch $branch_name && git checkout --detach && i && gr co master && gr sync && gr co $branch_name && gr top)
}

# Return a branch from main directory back to its worktree
wsr() {
    local branch_name="$1"
    
    # If no branch name provided, use current branch
    if [ -z "$branch_name" ]; then
        branch_name=$(git branch --show-current)
        echo "No branch specified, using current branch: $branch_name"
    fi
    
    local current_branch=$(git branch --show-current)

    echo "Checking out branch: $branch_name"
    (i && git checkout master && workstack switch "$branch_name" && gr sync && gr co "$branch_name" && gr top && i)
}
# Clean up a workstack and its associated tmux
wsrm() {
    if [ -z "$1" ]; then
        echo "Usage: wsrm <branch_name>"
        return 1
    fi
    
    local branch_name="$1"
    
    echo "Removing worktree: $branch_name"
    workstack remove "$branch_name"
    
    # Check if tmux is running and if the window exists
    if command -v tmux &> /dev/null && tmux list-windows -F "#{window_name}" 2>/dev/null | grep -q "^${branch_name}$"; then
        echo "Killing tmux window: $branch_name"
        tmux kill-window -t "$branch_name"
    fi
}

_custom_ws_completion() {
    local -a completions
    local -a completions_with_descriptions
    local -a response
    (( ! $+commands[workstack] )) && return 1

    # Inject "switch" as the first argument to workstack
    # Build the words array with "workstack switch" followed by your script's arguments
    local -a workstack_words
    workstack_words=("workstack" "switch" "${words[@]:1}")
    
    # Adjust COMP_CWORD to account for the added "switch" word
    response=("${(@f)$(env COMP_WORDS="${workstack_words[*]}" COMP_CWORD=$((CURRENT)) _WORKSTACK_COMPLETE=zsh_complete workstack)}")

    for type key descr in ${response}; do
        if [[ "$type" == "plain" ]]; then
            if [[ "$descr" == "_" ]]; then
                completions+=("$key")
            else
                completions_with_descriptions+=("$key":"$descr")
            fi
        elif [[ "$type" == "dir" ]]; then
            _path_files -/
        elif [[ "$type" == "file" ]]; then
            _path_files -f
        fi
    done

    if [ -n "$completions_with_descriptions" ]; then
        _describe -V unsorted completions_with_descriptions -U
    fi

    if [ -n "$completions" ]; then
        compadd -U -V unsorted -a completions
    fi
}

compdef _custom_ws_completion wsp 
compdef _custom_ws_completion wsr 
compdef _custom_ws_completion wsrm 

po() { 
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    git branch --sort=-committerdate | sed 's/^[* ]*//' | while read branch; do
        if [ "$branch" != "$current_branch" ]; then
            if [ -z "$(git log -1 --since='7 days ago' --format=format:x "$branch")" ]; then
		git branch -D "$branch"
	    fi
	fi
    done
}

command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# opencode
export PATH=$HOME/.opencode/bin:$PATH
