#!/bin/bash

# shellcheck source=/dev/null
source ~/Workspace/automation/config/env.sh

ACTION="meeting_stop"
TIMESTAMP=$(date -Iseconds)
LOG_FILE=~/Workspace/automation/vars/logs/discord.log

DISCORD_MEETING_STOP_SCRIPT=~/Workspace/automation/discord/meeting_stop_bot.sh
DISCORD_BOT_ENTRYPOINT=~/Workspace/automation/discord/lib/bot.js
PID_FILE=~/Workspace/automation/vars/pids/discord-bot.pid
BOT_PIDS=$(ps -ax -o pid=,command= | awk -v entrypoint="$DISCORD_BOT_ENTRYPOINT" 'index($0, entrypoint) && $0 !~ /awk/ {print $1}')
BOT_COUNT=$(printf "%s\n" "$BOT_PIDS" | awk 'NF {c++} END {print c+0}')
MEETING_STOP_RESULT="ok"
KILL9_USED="no"

if [ "$BOT_COUNT" -eq 0 ]; then
  rm -f "$PID_FILE"
  echo "$TIMESTAMP|INFO|$ACTION|0|discord_bot|already_stopped" >> "$LOG_FILE"
  echo "{\"status\":\"SUCCESS\",\"action\":\"$ACTION\",\"message\":\"Bot already offline\"}"
  exit 0
fi

if sh "$DISCORD_MEETING_STOP_SCRIPT"; then
  echo "$TIMESTAMP|INFO|$ACTION|0|meeting|stopped" >> "$LOG_FILE"
else
  echo "$TIMESTAMP|ERROR|$ACTION|40|meeting|stop_failed" >> "$LOG_FILE"
  MEETING_STOP_RESULT="failed"
fi

CURRENT_BOT_PIDS=$(ps -ax -o pid=,command= | awk -v entrypoint="$DISCORD_BOT_ENTRYPOINT" 'index($0, entrypoint) && $0 !~ /awk/ {print $1}')
CURRENT_COUNT=$(printf "%s\n" "$CURRENT_BOT_PIDS" | awk 'NF {c++} END {print c+0}')

if [ "$CURRENT_COUNT" -gt 0 ]; then
  for PID in $CURRENT_BOT_PIDS; do
    kill "$PID" 2>/dev/null || true
  done
fi

sleep 2

REMAINING_BOT_PIDS=$(ps -ax -o pid=,command= | awk -v entrypoint="$DISCORD_BOT_ENTRYPOINT" 'index($0, entrypoint) && $0 !~ /awk/ {print $1}')
REMAINING_COUNT=$(printf "%s\n" "$REMAINING_BOT_PIDS" | awk 'NF {c++} END {print c+0}')

if [ "$REMAINING_COUNT" -gt 0 ]; then
  echo "$TIMESTAMP|INFO|$ACTION|0|discord_bot|term_timeout_fallback_kill9" >> "$LOG_FILE"
  KILL9_USED="yes"
  for PID in $REMAINING_BOT_PIDS; do
    kill -9 "$PID" 2>/dev/null || true
  done
  sleep 1
  REMAINING_BOT_PIDS=$(ps -ax -o pid=,command= | awk -v entrypoint="$DISCORD_BOT_ENTRYPOINT" 'index($0, entrypoint) && $0 !~ /awk/ {print $1}')
  REMAINING_COUNT=$(printf "%s\n" "$REMAINING_BOT_PIDS" | awk 'NF {c++} END {print c+0}')
fi

if [ "$REMAINING_COUNT" -eq 0 ]; then
  rm -f "$PID_FILE"
fi

if [ "$REMAINING_COUNT" -gt 0 ]; then
  echo "$TIMESTAMP|ERROR|$ACTION|41|discord_bot|stop_failed" >> "$LOG_FILE"
  echo "{\"status\":\"ERROR\",\"action\":\"$ACTION\",\"message\":\"Unable to stop Discord bot\"}"
  exit 41
fi

echo "$TIMESTAMP|INFO|$ACTION|0|discord_bot|stopped" >> "$LOG_FILE"

if [ "$MEETING_STOP_RESULT" = "failed" ]; then
  echo "{\"status\":\"SUCCESS\",\"action\":\"$ACTION\",\"message\":\"Bot stopped, but meeting stop failed\"}"
elif [ "$KILL9_USED" = "yes" ]; then
  echo "{\"status\":\"SUCCESS\",\"action\":\"$ACTION\",\"message\":\"Meeting stopped (forced bot shutdown)\"}"
else
  echo "{\"status\":\"SUCCESS\",\"action\":\"$ACTION\",\"message\":\"Meeting stopped\"}"
fi

