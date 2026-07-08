# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/nboey/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-autosuggestions
	dotnet
)

source $ZSH/oh-my-zsh.sh

# Show full path in prompt instead of just folder name
PROMPT='%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ ) %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)'

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Yazi wrapper — cd to last visited directory on exit
function y() {
  local tmp
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" ]] && [[ "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Git Worktree Add — create (or refuse a duplicate) a worktree for a remote
# branch or a GitHub PR, then cd into it.
#   gwta <branch>               branch mode (bare, non-numeric arg)
#   gwta -b|--branch <branch>   branch mode, forced (e.g. a branch named "42")
#   gwta <number>               PR mode (bare, all-digits arg)
#   gwta -p|--pull-request <n>  PR mode, forced
#   gwta ls | list              list origin branches + their open PRs
#   gwta -h|--help              usage
# The worktree is created at <repo-root>/../<slug> (all '/' in the branch name
# replaced with '-') so worktrees sit as flat siblings of the main clone.
#
# The oh-my-zsh git plugin aliases `gwta` to `git worktree add`; drop that alias
# (this runs after oh-my-zsh is sourced) so the name resolves to our function.
# `gwt` (the plugin's `git worktree` alias) is deliberately left untouched.
unalias gwta 2>/dev/null

# Helper for `gwta ls` / `gwta list`: list origin branches, annotating those
# that have an open same-repo PR. Branches with a PR sort to the top (newest PR
# first); plain branches sort alphabetically at the bottom. The default branch
# (origin HEAD) and fork PRs are omitted. Works without gh (branches only).
function _gwta_list() {
  emulate -L zsh
  git rev-parse --show-toplevel >/dev/null 2>&1 || {
    echo "gwta: not inside a git repository" >&2
    return 1
  }

  # One round-trip to origin for every ref, including the HEAD symref.
  local remote_refs
  remote_refs="$(git ls-remote --symref origin 2>/dev/null)" || {
    echo "gwta: could not reach origin" >&2
    return 1
  }

  local default_branch
  default_branch="$(print -r -- "$remote_refs" | \
    awk '$1=="ref:" && $3=="HEAD"{s=$2; sub(/^refs\/heads\//,"",s); print s; exit}')"

  local -a branches
  branches=("${(@f)$(print -r -- "$remote_refs" | \
    awk '$1!="ref:" && $2 ~ /^refs\/heads\//{s=$2; sub(/^refs\/heads\//,"",s); print s}')}")

  # Map branch -> "<number>\t<isDraft>\t<title>" for open, same-repo PRs.
  typeset -A prmap
  local draft=""   # declared once here so it stays local even when gh is absent
  if command -v gh >/dev/null 2>&1; then
    local num br title
    while IFS=$'\t' read -r num br draft title; do
      [[ -n "$br" ]] && prmap[$br]="$num"$'\t'"$draft"$'\t'"$title"
    done < <(gh pr list --state open --limit 300 \
               --json number,headRefName,isDraft,title,isCrossRepository \
               --jq '.[] | select(.isCrossRepository == false) | "\(.number)\t\(.headRefName)\t\(.isDraft)\t\(.title)"' 2>/dev/null)
  fi

  # Colour open (non-draft) PRs green on a terminal; drafts keep the default
  # colour. GWTA_FORCE_COLOR forces colour on (e.g. for `gwta ls | less -R`).
  local c_green="" c_reset=""
  if [[ -t 1 || -n "${GWTA_FORCE_COLOR:-}" ]]; then
    c_green=$'\e[32m'; c_reset=$'\e[0m'
  fi

  # Partition branches into PR-annotated and plain, dropping the default branch.
  typeset -A pr_display
  local -a branch_only
  local b n t rec rest   # 'draft' is already local from the PR read loop above
  for b in $branches; do
    [[ -z "$b" ]] && continue
    [[ -n "$default_branch" && "$b" == "$default_branch" ]] && continue
    if [[ -n "${prmap[$b]:-}" ]]; then
      rec="${prmap[$b]}"
      n="${rec%%$'\t'*}"; rest="${rec#*$'\t'}"
      draft="${rest%%$'\t'*}"; t="${rest#*$'\t'}"
      if [[ "$draft" == "true" ]]; then
        pr_display[$n]="#$n [$b]: $t"                     # draft -> default colour
      else
        pr_display[$n]="${c_green}#$n [$b]: $t${c_reset}" # open  -> green
      fi
    else
      branch_only+=("[$b]")
    fi
  done

  if [[ ${#pr_display} -eq 0 && ${#branch_only} -eq 0 ]]; then
    echo "gwta: no branches on origin (besides its default)" >&2
    return 0
  fi

  # PRs first, newest number first; then plain branches alphabetically.
  local -a nums
  nums=(${(kn)pr_display})   # keys, numeric ascending
  nums=(${(Oa)nums})         # reverse -> descending
  for n in $nums; do print -r -- "${pr_display[$n]}"; done
  for b in ${(oi)branch_only}; do print -r -- "$b"; done
}

function gwta() {
  emulate -L zsh
  local usage='usage: gwta <branch> | -b|--branch <branch> | <pr-number> | -p|--pull-request <n> | ls|list'
  local mode="" arg=""

  case "$1" in
    -h|--help)          echo "$usage"; return 0 ;;
    ls|list)            _gwta_list; return $? ;;
    -b|--branch)        mode="branch"; arg="$2" ;;
    -p|--pull-request)  mode="pr";     arg="$2" ;;
    -*)                 echo "gwta: unknown option '$1'" >&2; echo "$usage" >&2; return 1 ;;
    *)                  arg="$1" ;;
  esac

  if [[ -z "$arg" ]]; then
    echo "gwta: missing branch/PR argument" >&2
    echo "$usage" >&2
    return 1
  fi

  # Auto-detect: a bare all-digits argument means a PR number.
  if [[ -z "$mode" ]]; then
    if [[ "$arg" =~ '^[0-9]+$' ]]; then mode="pr"; else mode="branch"; fi
  fi

  # Must be inside a git repository.
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "gwta: not inside a git repository" >&2
    return 1
  }

  # Resolve the branch name.
  local branch
  if [[ "$mode" == "pr" ]]; then
    if ! command -v gh >/dev/null 2>&1; then
      echo "gwta: gh (GitHub CLI) is required for PR mode" >&2
      return 1
    fi
    local prdata
    prdata="$(gh pr view "$arg" --json headRefName,isCrossRepository \
      --jq '.headRefName + "\t" + (.isCrossRepository|tostring)' 2>/dev/null)" || {
      echo "gwta: could not look up PR #$arg" >&2
      return 1
    }
    branch="${prdata%%$'\t'*}"
    local cross="${prdata##*$'\t'}"
    if [[ "$cross" == "true" ]]; then
      echo "gwta: PR #$arg is from a fork (cross-repository); not supported" >&2
      return 1
    fi
    if [[ -z "$branch" ]]; then
      echo "gwta: could not determine branch for PR #$arg" >&2
      return 1
    fi
    echo "gwta: PR #$arg -> branch '$branch'"
  else
    branch="$arg"
  fi

  # Compute the destination: a flat sibling of the repo root.
  local slug="${branch//\//-}"
  local dest="${root:h}/$slug"

  # Refuse if a worktree already exists for this branch or the path is taken.
  if git worktree list --porcelain | grep -qxF "branch refs/heads/$branch"; then
    echo "gwta: a worktree for '$branch' already exists (see: git worktree list)" >&2
    return 1
  fi
  if [[ -e "$dest" ]]; then
    echo "gwta: destination '$dest' already exists" >&2
    return 1
  fi

  # Pull the branch from origin.
  if ! git fetch origin "$branch" 2>/dev/null; then
    echo "gwta: branch '$branch' not found on origin" >&2
    return 1
  fi
  if ! git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    echo "gwta: 'origin/$branch' not found after fetch" >&2
    return 1
  fi

  # Create the worktree (reuse an existing local branch if there is one).
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$dest" "$branch" || return 1
  else
    git worktree add --track -b "$branch" "$dest" "origin/$branch" || return 1
  fi

  builtin cd "$dest" && echo "gwta: switched to worktree at $dest"
}

# Zoxide — smarter cd
eval "$(zoxide init zsh)"

# Claude Code aliases
alias ccd='claude --dangerously-skip-permissions --remote-control'

# Add dotnet tools
export PATH="$PATH:/Users/nboey/.dotnet/tools"

# Add Avalonia license key
export AVALONIA_LICENSE_KEY=avln_off_key:v1:AQAAAMMAAAAfiwgAAAAAAAADbY67CgJBDEWzaKFWdj5A8QdWRAVhO1GwshOtszNRB4fJkswqdn66KGqzprnhnARuAgDTBrynPptO5q/l+Fh0X5kAQA3DvQUAA7yi5+AwRWPIk2Ck1LtcUBxpZ/mx4xWHKOx1vCXrsFflB8r3jm79Px8oF8u30K2q1Rkl6rAqdkK0xogbcbbzq1igGPKp4aDsafTjlq7kuSBJI7PX70G7ELaliVleqguk2iwVT5SpvTwBXTCkQyABAAAAAQAATNXZsPNvlPPA41ERijdBZHYhjjV3FTVDXAodpU5fr3cC3hZB5+rxdKkAVGpuzyvbQRS3FK78NfbZ7MCbuahfJONZTN4P5/Nwvt/4O7QLLEC+70VSg3mX58f5KpC1/UYQcZN+sqN+qIrnKfl9pBL/BoRMWhlueFR0I+1Xy0dNfnvgPtDT739jknxYRCHBGU5ADr5cBcxZpW5P9vY9K3Wv1a73arjD1nFMdvWqiBx1I3LDswc2x2Q0zSJKkaglbTaOcdTiDtNrI0hmdWIi+l09wYs+H2EhqiLB1k7SXFv92CmKbLQDNBzr7cZ0xSdCK6DJSK7Z+xIvUSuPSXjOwDYbGw==:AQAAAMkAAAAfiwgAAAAAAAADbY5BawJBDIUj9lAKgjetUOkf2EVsoeCtKHjqTew5O/O0Q6eTJZlVvPnTxaJe1lxe+L4EXoeIpo/0Pw9v08n7edkcP4bn7BBRl9PhiYheeMdRUuCCnUOEckYRQ6WsATb4vNhyLimrRCu/4AM/t/k3qnXAfnTng/XXyz4N22r+w5pt3BYrBRaceanBD24Va1aHWDhJJhGvN+6xQ5QaWmSRaNeDfq3iG5dnVWMhwazXGG8x0ybl8IcTjBmX6CQBAAAAAQAAZCxLq29/OysHSf9idulCR/ToFF73oFBhbD/DP0MNWpyR0CQuSfkXMQN0bCIl62epToMap1/EuObHUhvw6ZsTZueIODU/Evi6bsf2+iERrbQZaqSQA36Po3/Ch0zVm9Z/XqfJHVJ5vNin/4sFmgrq2ovNVCRn8EAfPUxz8xZnUrizFHv28WxLt8KHFzvb5e0RenmEmDGCoEBwkm7a18RV7JjS83StEh6oDyo9OMORLTYnATgenEI1k5kedRQXQchDSF8Ru1eaYVslov6UHGWFS0bhMN1/T/aXgslJCfoeJEiInaxU/h7Uw3VJc+8SjfgnR/9rQOUTZ7BcX9cif0mo7g==

# Added by get-aspire-cli.sh
export PATH="$HOME/.aspire/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export EDITOR="nvim"

# pnpm
export PNPM_HOME="/Users/nboey/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export CHROMATIC_PROJECT_TOKEN="chpt_b506e7b703c381f"


# Added by Antigravity CLI installer
export PATH="/Users/nboey/.local/bin:$PATH"

# pnpm global package binaries (added by cyrus-setup)
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
