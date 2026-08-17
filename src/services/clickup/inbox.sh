#!/usr/bin/env bash

_clickup_inbox_log() {
  local level=$1
  local code=$2
  local detail=$3

  printf '%s|%s|clickup_inbox_task_create|%s|-|%s\n' \
    "$(date -Iseconds)" "$level" "$code" "$detail" >&2
}

# shellcheck disable=SC2034 # Results are assigned through caller-owned namerefs.
clickup_inbox_task_create() {
  local payload=$1
  local -n response_body_ref=$2
  local -n http_code_ref=$3
  local response
  local curl_status

  if response=$(curl --silent --show-error \
    --write-out $'\n%{http_code}' \
    --request POST \
    "$API_CLICKUP_BASE_URL/api/v2/list/$CLICKUP_INBOX_ID/task" \
    --header "Authorization: $API_CLICKUP_TOKEN" \
    --header 'Content-Type: application/json' \
    --data "$payload" 2>&1); then
    curl_status=0
  else
    curl_status=$?
  fi

  if ((curl_status != 0)); then
    response_body_ref=
    http_code_ref=000
    _clickup_inbox_log ERROR "$curl_status" transport_failure
    return 10
  fi

  if [[ $response != *$'\n'* ]]; then
    response_body_ref=
    http_code_ref=000
    _clickup_inbox_log ERROR 000 invalid_http_response
    return 10
  fi

  response_body_ref=${response%$'\n'*}
  http_code_ref=${response##*$'\n'}

  if [[ $http_code_ref =~ ^[0-9]{3}$ ]] \
    && ((10#$http_code_ref >= 200 && 10#$http_code_ref < 300)); then
    _clickup_inbox_log INFO "$http_code_ref" created
    return 0
  fi

  _clickup_inbox_log ERROR "$http_code_ref" http_failure
  return 10
}
