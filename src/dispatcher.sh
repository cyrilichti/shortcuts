#!/usr/bin/env bash

dispatch() (
  local action=$1
  shift

  local action_name
  local log_file
  local response
  local code
  local level

  action_name=${action%_action}
  log_file="$(dirname "${BASH_SOURCE[0]}")/../vars/logs/$action_name.log"

  if response=$("$action" "$@"); then
    code=0
    level=INFO
  else
    code=$?
    level=ERROR
  fi

  if [[ -z $response ]]; then
    if [[ $code -eq 0 ]]; then
      code=1
    fi
    level=ERROR
    response="{\"status\":\"ERROR\",\"action\":\"$action_name\",\"message\":\"Unexpected action failure\"}"
  fi

  printf '%s|%s|%s|%s|dispatch\n' \
    "$(date -Iseconds)" "$level" "$action_name" "$code" >>"$log_file"

  printf '%s\n' "$response"
  return "$code"
)
