# shellcheck shell=bash
#
# Global app config (non-secret, safe to track). Secrets stay in host env
# (e.g. ~/.zsh_secrets via dotfiles): CLICKUP_TOKEN, DISCORD_BOT_TOKEN,
# CURSOR_API_KEY.

# clickup/inbox_add.sh
export CLICKUP_API_BASE_URL="https://api.clickup.com"
export CLICKUP_BASE_URL="https://app.clickup.com"
export CLICKUP_INBOX_ID="901521081133"
export CLICKUP_INBOX_PATH="90152254070/v/l/6-${CLICKUP_INBOX_ID}-1"

# discord/ (fill guild + voice channel IDs; bot token stays in host secrets)
export DISCORD_MEETING_GUILD_ID=""
export DISCORD_MEETING_VOICE_CHANNEL_ID=""
