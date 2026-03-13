#!/bin/bash

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

# Claude Code aliases
alias ccd='claude --dangerously-skip-permissions'
alias ccdc='claude --dangerously-skip-permissions --continue'
