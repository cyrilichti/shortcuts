#!/bin/bash

# shellcheck source=/dev/null
source ~/Workspace/automation/config/env.sh

ACTION="meeting_transcribe"
TIMESTAMP=$(date -Iseconds)
LOG_FILE=~/Workspace/automation/vars/logs/discord.log
AUDIO_DIR=~/Workspace/automation/vars/runtime/audios
TRANSCRIPTS_DIR=~/Workspace/automation/vars/runtime/transcripts
WHISPER_BIN=~/homebrew/bin/whisper-cli
WHISPER_MODEL=~/Workspace/automation/vars/runtime/ggml-large-v3.bin
WHISPER_LANGUAGE=fr

SESSION_ID="${1:-}"

set -- "$AUDIO_DIR/${SESSION_ID}"__speaker-*.wav
if [ ! -e "$1" ]; then
  echo "$TIMESTAMP|ERROR|$ACTION|61|session|not_found|session=$SESSION_ID" >> "$LOG_FILE"
  echo "{\"status\":\"ERROR\",\"action\":\"$ACTION\",\"message\":\"No audio files found for session_id\"}"
  exit 61
fi

TRANSCRIPT_FILE="$TRANSCRIPTS_DIR/$SESSION_ID.md"
{
  printf "# Meeting Transcript\n\n"
  printf "## 📅 Session Info\n\n"
  printf "- Session: \`%s\`\n" "$SESSION_ID"
  printf "- Generated at: \`%s\`\n\n" "$TIMESTAMP"
  printf "---\n\n"
  printf "## 🗣 Transcript\n\n"
} > "$TRANSCRIPT_FILE"

TRANSCRIBED_COUNT=0

for AUDIO_FILE in "$@"; do
  BASENAME=$(basename "$AUDIO_FILE")
  SPEAKER_RAW="${BASENAME#*__speaker-}"
  SPEAKER_RAW="${SPEAKER_RAW%.wav}"
  SPEAKER_ID="${SPEAKER_RAW%%__name-*}"
  SPEAKER_NAME="$SPEAKER_ID"
  ENCODED_NAME=""
  DECODED_NAME=""
  case "$SPEAKER_RAW" in
    *__name-*)
      ENCODED_NAME="${SPEAKER_RAW#*__name-}"
      ;;
  esac
  if [ -n "$ENCODED_NAME" ]; then
    BASE64_NAME=$(printf "%s" "$ENCODED_NAME" | tr '_-' '/+')
    BASE64_MOD=$(( ${#BASE64_NAME} % 4 ))
    if [ "$BASE64_MOD" -eq 2 ]; then
      BASE64_NAME="${BASE64_NAME}=="
    elif [ "$BASE64_MOD" -eq 3 ]; then
      BASE64_NAME="${BASE64_NAME}="
    fi
    DECODED_NAME=$(printf "%s" "$BASE64_NAME" | base64 -D 2>/dev/null || true)
    if [ -n "$DECODED_NAME" ]; then
      SPEAKER_NAME="$DECODED_NAME"
    fi
  fi
  OUTPUT_PREFIX="/tmp/meeting-transcribe-${SESSION_ID}-${SPEAKER_ID}-$$"
  OUTPUT_TEXT_FILE="${OUTPUT_PREFIX}.txt"

  rm -f "$OUTPUT_TEXT_FILE"

  "$WHISPER_BIN" -m "$WHISPER_MODEL" -f "$AUDIO_FILE" -l "$WHISPER_LANGUAGE" -otxt -of "$OUTPUT_PREFIX" >/dev/null 2>&1
  WHISPER_EXIT_CODE=$?

  if [ "$WHISPER_EXIT_CODE" -ne 0 ] || [ ! -f "$OUTPUT_TEXT_FILE" ]; then
    rm -f "$OUTPUT_TEXT_FILE"
    echo "$TIMESTAMP|ERROR|$ACTION|62|transcription|failed|session=$SESSION_ID|speaker=$SPEAKER_ID" >> "$LOG_FILE"
    echo "{\"status\":\"ERROR\",\"action\":\"$ACTION\",\"message\":\"Failed to transcribe session audio\"}"
    exit 62
  fi

  {
    printf "### 👤 %s\n\n" "$SPEAKER_NAME"
    printf "- User ID: \`%s\`\n" "$SPEAKER_ID"
    printf "- Source: \`%s\`\n\n" "$BASENAME"
    while IFS= read -r LINE || [ -n "$LINE" ]; do
      printf "%s\n" "$LINE"
    done < "$OUTPUT_TEXT_FILE"
    printf "\n\n---\n\n"
  } >> "$TRANSCRIPT_FILE"

  rm -f "$OUTPUT_TEXT_FILE"
  TRANSCRIBED_COUNT=$((TRANSCRIBED_COUNT + 1))
done

echo "$TIMESTAMP|INFO|$ACTION|0|transcription|completed|session=$SESSION_ID|files=$TRANSCRIBED_COUNT|file=$TRANSCRIPT_FILE" >> "$LOG_FILE"
echo "{\"status\":\"SUCCESS\",\"action\":\"$ACTION\",\"message\":\"Meeting transcription completed\",\"session_id\":\"$SESSION_ID\",\"files\":$TRANSCRIBED_COUNT,\"transcript_file\":\"$TRANSCRIPT_FILE\"}"
