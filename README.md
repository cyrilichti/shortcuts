# Shortcuts

A personal automation layer designed to reduce cognitive load and execution friction for daily workflows.

---

## Stack (layers)

- **Interface**: iPhone Shortcuts (trigger + UI)
- **Transport**: SSH
- **Execution**: macOS + shell scripts
- **Targets**: external APIs (ClickUp, Git, Discord, etc.)

---

## Architecture

iPhone (Shortcuts)  
↓  
SSH (secure trigger)  
↓  
Mac (execution unit)  
↓  
Shell scripts  
↓  
External APIs (ClickUp, Git, etc.)

---

## Philosophy

The goal is simple:

> Reduce effort and cognitive load for repetitive workflows by turning them into one-tap actions.

Instead of:
- opening tools
- navigating UIs
- repeating manual steps

I trigger workflows directly from my iPhone.

---

## Why this exists

I initially thought about building a Stream Deck setup.

Instead, I realized:

- iOS Shortcuts already provide a distributed control surface
- iCloud sync makes shortcuts available across devices
- SSH enables full remote execution on a central machine

So I combined:

- Shortcuts = UI layer
- Mac = orchestration layer
- Shell scripts = logic layer

---

## Prerequisites

### macOS (all workflows)

- iPhone Shortcuts + SSH to the Mac execution unit
- Host secrets for tokens/keys (see Configuration)
- Non-secret app config in `config/app.sh`

### Discord meeting

Install whisper.cpp CLI on the Mac:

```bash
brew install whisper-cpp
```

Download IA model locally

```bash
curl -L "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin?download=true" -o ~/Workspace/shortcuts/vars/runtime/ggml-large-v3.bin
```

#### Meeting summary (Cursor API)

Required for the summary step when a meeting was started with **record**.

Install the Cursor CLI on the Mac:

```bash
brew install jq
```

#### Node.js

- **Node.js LTS** on the Mac (currently **v24.x** Active LTS)

Install or upgrade with Homebrew:

#### npm dependencies (repo root)

Install once after cloning or pulling dependency changes:

```bash
cd ~/Workspace/shortcuts
npm install
```

---

## iPhone <-> Mac setup (Shortcuts + SSH)

- Enable iCloud sync for Shortcuts (iPhone settings).
- On Mac, enable `System Settings -> General -> Sharing -> Remote Sessions`.

---

## Configuration

**Secrets** (host env only, not in this repo — see [dotfiles](https://github.com/cyrilichti/dotfiles)):

- `CLICKUP_TOKEN`
- `DISCORD_BOT_TOKEN`
- `CURSOR_API_KEY`

**Config** (`config/app.sh`, tracked):

- ClickUp API/base URLs, inbox id/path
- `DISCORD_MEETING_GUILD_ID`, `DISCORD_MEETING_VOICE_CHANNEL_ID` (fill locally if empty)

Workflow SSH entry points load `config/app.sh` when they need non-secret
config (helpers inherit the exported env). A later routing façade can own
that load. Scripts never source a repo-local secrets file.

---

## Discord bot setup

- Enable Developer Mode in Discord (`User Settings -> Advanced`).
- In [Discord Developer Portal](https://discord.com/developers/applications), create an application and a bot.
- Copy bot token into host secrets as `DISCORD_BOT_TOKEN`.
- Invite the bot with scope `bot` and permissions `View Channels`, `Connect` (optional `Speak`).
- Set server and voice channel IDs in `config/app.sh`:
  - `DISCORD_MEETING_GUILD_ID`
  - `DISCORD_MEETING_VOICE_CHANNEL_ID`

---

## Design principles

- Minimal cognitive friction
- One SSH trigger = one intent
- No UI navigation required for frequent tasks
- iPhone is trigger + UI only; Mac executes
- Secrets stay on the Mac (host env), never in Shortcuts / iCloud

---

## Security

- No secrets on the iPhone or in the repo
- Execution on a trusted local Mac
- SSH as the secure transport layer

---

## Future extensions (checklist)

Prioritized by ROI: frequency, time saved, implementation effort, and risk.

- [x] Create a quick ClickUp inbox task
- [x] Record a Discord meeting (join + record as sole entry)
- [x] Stop a Discord meeting session
- [x] Transcribe a recorded meeting
- [x] Summarize a meeting transcript
- [ ] Notify teammates on Rocket.Chat when meeting starts
- [ ] Prepare a meeting workspace (Discord, ClickUp, browser, window layout)
- [ ] Convert Os ticket task into clickup task
- [ ] Create multiple inbox tasks from a multi-line list
- [ ] Schedule a Discord meeting
- [ ] Send a reusable Rocket.Chat notification
- [ ] Add generic macOS workspace actions (split windows, fullscreen, open context)

---

## Vision

This is a personal control layer for my digital workflows.

Not a product.  
Not a framework.  
Just a system to execute daily work faster, with less friction.