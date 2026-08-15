# shellcheck shell=bash
#
# Required export names for this repo (no secrets). Provide values in the host
# environment — see README Configuration.

# clickup/inbox_add.sh
export CLICKUP_TOKEN=""
export CLICKUP_INBOX_ID=""

# discord/
export DISCORD_BOT_TOKEN=""
export DISCORD_MEETING_GUILD_ID=""
export DISCORD_MEETING_VOICE_CHANNEL_ID=""

# discord/meeting_summarize.sh (required for SSH: login keychain is locked)
export CURSOR_API_KEY=""
