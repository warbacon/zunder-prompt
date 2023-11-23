# # Source gitstatus.plugin.zsh
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"
source "${0:A:h}/gitstatus/gitstatus.plugin.zsh" || return

function gitstatus_prompt_update() {
  emulate -L zsh
  typeset -g  GITSTATUS_PROMPT=''
  typeset -gi GITSTATUS_PROMPT_LEN=0

  # Call gitstatus_query synchronously.
  gitstatus_query 'MY'                  || return 1  # error
  [[ $VCS_STATUS_RESULT == 'ok-sync' ]] || return 0  # not a git repo

  local      clean='%5F'  # magenta foreground
  local   modified='%3F'  # yellow foreground
  local  untracked='%4F'  # blue foreground
  local conflicted='%1F'  # red foreground

  [[ "$TERM" != "linux" ]] && local git_icon=" " # set git_icon if not in tty
  local p="on %B${clean}${git_icon}"

  local where  # branch name, tag or commit
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    where=$VCS_STATUS_LOCAL_BRANCH
  elif [[ -n $VCS_STATUS_TAG ]]; then
    p+='#'
    where=$VCS_STATUS_TAG
  else
    p+='@'
    where=${VCS_STATUS_COMMIT[1,8]}
  fi

  (( $#where > 32 )) && where[13,-13]="…"  # truncate long branch names and tags
  p+="${where//\%/%%}%b"                   # escape %

  # ⇣42 if behind the remote.
  (( VCS_STATUS_COMMITS_BEHIND )) && p+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
  # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
  (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && p+=" "
  (( VCS_STATUS_COMMITS_AHEAD  )) && p+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
  # ⇠42 if behind the push remote.
  (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && p+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
  (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && p+=" "
  # ⇢42 if ahead of the push remote; no leading space if also behind: ⇠42⇢42.
  (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && p+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
  # *42 if have stashes.
  (( VCS_STATUS_STASHES        )) && p+=" ${clean}*${VCS_STATUS_STASHES}"
  # 'merge' if the repo is in an unusual state.
  [[ -n $VCS_STATUS_ACTION     ]] && p+=" ${conflicted}${VCS_STATUS_ACTION}"
  # ~42 if have merge conflicts.
  (( VCS_STATUS_NUM_CONFLICTED )) && p+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
  # +42 if have staged changes.
  (( VCS_STATUS_NUM_STAGED     )) && p+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
  # !42 if have unstaged changes.
  (( VCS_STATUS_NUM_UNSTAGED   )) && p+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
  # ?42 if have untracked files. It's really a question mark, your font isn't broken.
  (( VCS_STATUS_NUM_UNTRACKED  )) && p+=" ${untracked}?${VCS_STATUS_NUM_UNTRACKED}"

  GITSTATUS_PROMPT="${p}%f"

  # The length of GITSTATUS_PROMPT after removing %f, %b, %F and %B.
  GITSTATUS_PROMPT_LEN="${(m)#${${${GITSTATUS_PROMPT//\%\%/x}//\%(f|<->F)}//\%[Bb]}}"
}

# Start gitstatusd instance with name "MY". The same name is passed to
# gitstatus_query in gitstatus_prompt_update. The flags with -1 as values
# enable staged, unstaged, conflicted and untracked counters.
gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

function check_first_prompt() {
  if [[ $FIRST_PROMPT == false ]]; then
    printf "\n"
  else
    FIRST_PROMPT=false
  fi
}

autoload -Uz add-zsh-hook

# On every prompt, fetch git status and set GITSTATUS_PROMPT.
add-zsh-hook precmd gitstatus_prompt_update

# Adds a new line if it's not the first prompt.
add-zsh-hook precmd check_first_prompt

# Enable/disable the right prompt options.
setopt no_prompt_bang prompt_percent prompt_subst

# Default prompt char
ZUNDER_PROMPT_CHAR='❯'
[[ "$TERM" == "linux" ]] && ZUNDER_PROMPT_CHAR='>'  # switch to > in tty mode

# Prompt used in multiline commands
PROMPT2="%8F·%f "

# The current directory gets truncated from the left if the whole prompt doesn't fit on the line.
PROMPT='%B%6F%$((-GITSTATUS_PROMPT_LEN-1))<…<%~%<<%f%b'   # cyan current working directory
PROMPT+='${GITSTATUS_PROMPT:+ $GITSTATUS_PROMPT}'         # git status
PROMPT+=$'\n'                                             # new line
PROMPT+='%F{%(?.2.1)}${ZUNDER_PROMPT_CHAR}%f '            # $ZUNDER_PROMPT_CHAR green/red (ok/error)
