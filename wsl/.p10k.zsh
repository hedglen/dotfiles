# WSL-specific Powerlevel10k prompt: classic powerline look with practical segments.
source ~/.oh-my-zsh/custom/themes/powerlevel10k/config/p10k-classic.zsh

# Keep the louder classic look but focus it on the segments we actually use.
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
  os_icon
  context
  dir
  vcs
  newline
  prompt_char
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status
  command_execution_time
  background_jobs
  node_version
  virtualenv
  pyenv
  anaconda
  time
)

typeset -g POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true
typeset -g POWERLEVEL9K_STATUS_OK=true
typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true
typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false
typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=true

# Make the multiline prompt feel intentionally structured instead of empty.
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='─'

# Slightly stronger identity in WSL.
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='%n@%m'
