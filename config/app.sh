# shellcheck shell=bash
#
# App config loaded by SSH entry points. Two sections:

# --- Host secrets (must already be set in the environment) ---
export API_CLICKUP_TOKEN="$API_CLICKUP_TOKEN"
export BOT_DISCORD_TOKEN="$BOT_DISCORD_TOKEN"
export API_CURSOR_TOKEN="$API_CURSOR_TOKEN"

# clickup/inbox_add.sh
export CLICKUP_API_BASE_URL="https://api.clickup.com"
export CLICKUP_BASE_URL="https://app.clickup.com"
export CLICKUP_INBOX_ID="901521081133"
export CLICKUP_INBOX_PATH="90152254070/v/l/6-${CLICKUP_INBOX_ID}-1"

# discord/
export DISCORD_MEETING_GUILD_ID="687956938872324097"
export DISCORD_MEETING_VOICE_CHANNEL_ID="1504096124846346312"
