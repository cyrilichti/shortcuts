#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../services/clickup/priority.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../services/clickup/date.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../services/clickup/task.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../services/clickup/inbox.sh"

inbox_add_controller() {
  local title=${1-}
  local priority_text=${2-}
  local priority
  local start_date_ms
  local due_date_ms
  local payload
  local _response_body
  local _http_code
  local service_status

  clickup_date_get_from_now start_date_ms due_date_ms

  priority=$(clickup_priority_get_from_text "$priority_text")
  payload=$(clickup_task_payload_build "$title" "$priority" "$start_date_ms" "$due_date_ms")

  clickup_inbox_task_create "$payload" _response_body _http_code

  service_status=$?

  if ((service_status == 0)); then
    jq -cjn \
      --arg status SUCCESS \
      --arg action inbox_add \
      --arg message 'Inbox item added' \
      '{status: $status, action: $action, message: $message}'
    return
  fi

  jq -cjn \
    --arg status ERROR \
    --arg action inbox_add \
    --arg message 'ClickUp API error' \
    '{status: $status, action: $action, message: $message}'

  return "$service_status"
}
