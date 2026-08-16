#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CLI_INDEX="$REPO_ROOT/bin/shortcuts"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local haystack=$1
  local needle=$2
  local message=$3

  [[ "$haystack" == *"$needle"* ]] || fail "$message"
}

[[ ${BASH_VERSINFO[0]} -ge 5 ]] || fail "tests require Homebrew Bash 5 or newer"
command -v argc >/dev/null || fail "argc must be available on PATH"
[[ -x "$CLI_INDEX" ]] || fail "CLI index must exist and be executable"
[[ $(sed -n '1p' "$CLI_INDEX") == '#!/usr/bin/env bash' ]] || fail "CLI index must resolve Bash through env"

help_output=$("$CLI_INDEX" --help 2>&1)
command_names=$(printf '%s\n' "$help_output" | awk '
  /^COMMANDS:/ { in_commands = 1; next }
  in_commands && NF == 0 { exit }
  in_commands { print $1 }
')
expected_commands=$'meeting_record\nmeeting_stop\ninbox_add'
[[ "$command_names" == "$expected_commands" ]] || fail "help must discover exactly meeting_record, meeting_stop, and inbox_add"

inbox_help=$("$CLI_INDEX" inbox_add --help 2>&1)
assert_contains "$inbox_help" 'inbox_add [TITLE] [PRIORITY]' "inbox_add must expose two optional positional arguments"

eval_output=$(argc --argc-eval "$CLI_INDEX" inbox_add "multi word title" "high priority")
assert_contains "$eval_output" "argc_title='multi word title'" "quoted multiword title must remain one argument"
assert_contains "$eval_output" "argc_priority='high priority'" "quoted multiword priority must remain one argument"

argc --argc-export "$CLI_INDEX" | node -e '
  const fs = require("node:fs");
  const definition = JSON.parse(fs.readFileSync(0, "utf8"));
  const commands = Object.fromEntries(definition.subcommands.map(command => [command.name, command]));

  if (commands.meeting_record.positionals.length !== 0) process.exit(1);
  if (commands.meeting_stop.positionals.length !== 0) process.exit(1);

  const inboxArgs = commands.inbox_add.positionals;
  if (inboxArgs.length !== 2) process.exit(1);
  if (inboxArgs[0].id !== "title" || inboxArgs[0].required || inboxArgs[0].multiple) process.exit(1);
  if (inboxArgs[1].id !== "priority" || inboxArgs[1].required || inboxArgs[1].multiple) process.exit(1);
' || fail "argc schema must declare the expected zero-argument and optional single-value signatures"

if output=$("$CLI_INDEX" inbox_add title priority extra 2>&1); then
  fail "inbox_add must reject more than two positional arguments"
fi
[[ "$output" != \{* ]] || fail "inbox_add parsing errors must remain argc output"

if output=$("$CLI_INDEX" unknown_command 2>&1); then
  fail "unknown commands must be rejected"
fi
[[ "$output" != \{* ]] || fail "routing errors must remain argc output"

printf 'PASS: CLI index contract\n'
