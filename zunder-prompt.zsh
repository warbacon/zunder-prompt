# Source gitstatus.plugin.zsh
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
source "${0:A:h}/gitstatus/gitstatus.plugin.zsh" || return

# Sets GITSTATUS_PROMPT to reflect the state of the current git repository. Empty if not
# in a git repository. In addition, sets GITSTATUS_PROMPT_LEN to the number of columns
# $GITSTATUS_PROMPT will occupy when printed.
#
# Example:
#
#   GITSTATUS_PROMPT='master ⇣42⇡42 ⇠42⇢42 *42 merge ~42 +42 !42 ?42'
#   GITSTATUS_PROMPT_LEN=39
#
#   master  current branch
#      ⇣42  local branch is 42 commits behind the remote
#      ⇡42  local branch is 42 commits ahead of the remote
#      ⇠42  local branch is 42 commits behind the push remote
#      ⇢42  local branch is 42 commits ahead of the push remote
#      *42  42 stashes
#    merge  merge in progress
#      ~42  42 merge conflicts
#      +42  42 staged changes
#      !42  42 unstaged changes
#      ?42  42 untracked files
function gitstatus_prompt_update() {
  emulate -L zsh
  typeset -g  GITSTATUS_PROMPT=''
  typeset -gi GITSTATUS_PROMPT_LEN=0

  # Call gitstatus_query synchronously. Note that gitstatus_query can also be called
  # asynchronously; see documentation in gitstatus.plugin.zsh.
  gitstatus_query 'MY'                  || return 1  # error
  [[ $VCS_STATUS_RESULT == 'ok-sync' ]] || return 0  # not a git repo

  local      clean='%5F'   # magenta foreground
  local   modified='%3F'   # yellow foreground
  local  untracked='%4F'   # blue foreground
  local conflicted='%1F'   # red foreground

  local p

  local git_prefix="on "

  if [[ -n $DISPLAY ]]; then
    local git_icon=" "
  else
    local git_icon=""
  fi

  local where  # branch name, tag or commit
  if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
    where=$VCS_STATUS_LOCAL_BRANCH
  elif [[ -n $VCS_STATUS_TAG ]]; then
    p+='%f#'
    where=$VCS_STATUS_TAG
  else
    p+='%f@'
    where=${VCS_STATUS_COMMIT[1,8]}
  fi

  (( $#where > 32 )) && where[13,-13]="…"                  # truncate long branch names and tags
  p+="${git_prefix}%B${clean}${git_icon}${where//\%/%%}"   # escape %

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

  GITSTATUS_PROMPT="${p}%f%b"

  # The length of GITSTATUS_PROMPT after removing %f and %F.
  GITSTATUS_PROMPT_LEN="${(m)#${${GITSTATUS_PROMPT//\%\%/x}//\%(f|<->F)}}"
}

# Start gitstatusd instance with name "MY". The same name is passed to
# gitstatus_query in gitstatus_prompt_update. The flags with -1 as values
# enable staged, unstaged, conflicted and untracked counters.
gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'

# On every prompt, fetch git status and set GITSTATUS_PROMPT.
autoload -Uz add-zsh-hook
add-zsh-hook precmd gitstatus_prompt_update

# Enable/disable the right prompt options.
setopt no_prompt_bang prompt_percent prompt_subst

function preexec() {
  timer=$(date +%s%3N)
}

function precmd() {
  if [[ -n $ZUNDER_CHAR_SYMBOL && $ZUNDER_PROMPT_CHAR_SYMBOL != $ZUNDER_CHAR_SYMBOL ]]; then
    echo "ZUNDER_CHAR_SYMBOL is deprecated. Use ZUNDER_PROMPT_CHAR_SYMBOL instead."
    ZUNDER_PROMPT_CHAR_SYMBOL=$ZUNDER_CHAR_SYMBOL
  fi

  if [[ -n $ZUNDER_CHAR_COLOR && $ZUNDER_PROMPT_CHAR_COLOR != $ZUNDER_CHAR_COLOR ]]; then
    echo "ZUNDER_CHAR_COLOR is deprecated. Use ZUNDER_PROMPT_CHAR_COLOR instead."
    ZUNDER_PROMPT_CHAR_COLOR=$ZUNDER_CHAR_COLOR
  fi

  if [ $timer ]; then
    local now=$(date +%s%3N)
    local d_ms=$(($now-$timer))
    local d_s=$((d_ms / 1000))
    local ms=$((d_ms % 1000))
    local s=$((d_s % 60))
    local m=$(((d_s / 60) % 60))
    local h=$((d_s / 3600))
    if ((h > 0)); then elapsed=${h}h${m}m
    elif ((m > 0)); then elapsed=${m}m${s}s
    elif ((s >= 3)); then elapsed=${s}s
    else elapsed=0; fi

    if [[ $elapsed == 0 ]]; then
      elapsed=""
    else
      elapsed=" took %B%F{yellow}$elapsed%f%b"
    fi

    unset timer
  fi
}

# Default values for prompt customization variables.
if [[ -z $DISPLAY ]]; then
  ZUNDER_PROMPT_CHAR='>'        # default prompt character in tty
elif [[ -z $ZUNDER_PROMPT_CHAR ]]; then
  ZUNDER_PROMPT_CHAR=""        # default prompt character
fi

# You can use any color from 0 to 255 or a color name.
if [[ -z $ZUNDER_PROMPT_CHAR_COLOR ]]; then
  ZUNDER_PROMPT_CHAR_COLOR=3    # equivalent to yellow
fi

# Customize prompt. Put $GITSTATUS_PROMPT in it to reflect git status.
#
# Example:
#
#   ~/projects/skynet on  master ⇡42 took 3m2s
#     █
#
# The current directory gets truncated from the left if the whole prompt doesn't fit on the line.
PROMPT=$'\n'                                                           # new line
PROMPT+='%B%6F%$((-GITSTATUS_PROMPT_LEN-1))<…<%~%<<%f%b'               # cyan current working directory
PROMPT+='${GITSTATUS_PROMPT:+ $GITSTATUS_PROMPT}'                      # git status
PROMPT+='$elapsed'                                                     # time elapsed
PROMPT+=$'\n'                                                          # new line
PROMPT+=$'%F{%(?.$ZUNDER_PROMPT_CHAR_COLOR.1)}$ZUNDER_PROMPT_CHAR%f '  # specified color/red (ok/error)

