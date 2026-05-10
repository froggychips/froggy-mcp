# froggy-mcp 🐸

🌐 **English** · [Русский](README.ru.md)

> **MCP server that gives Claude Code access to your local Froggy context — screen, meetings, local LLM.**

[Froggy](https://github.com/froggychips/Froggy) runs on your Mac: it sees your screen via OCR,
transcribes calls, and runs a local LLM on 8 GB RAM. Claude Code is a powerful cloud model but
has no eyes. `froggy-mcp` connects them — Claude can query Froggy over its Unix socket without
any copy-paste.

**Status:** personal-use companion to Froggy. Not a product. Requires the
[Froggy daemon](https://github.com/froggychips/Froggy) running locally.

📬 Contact: [@froggychips](https://t.me/froggychips) on Telegram
📜 License: [MIT](LICENSE)

---

## Ecosystem

| Repo | Role |
|---|---|
| [Froggy](https://github.com/froggychips/Froggy) | Local LLM daemon, OCR, screen context, memory management |
| **froggy-mcp** | MCP bridge → Claude Code |
| [froggy-sre](https://github.com/froggychips/froggy-sre) | SRE incident response agent — K8s alert analysis pipeline |

```
Claude Code  ←—stdio / JSON-RPC—→  froggy-mcp  ←—unix socket / JSON-line—→  Froggy daemon
Claude Code  ←—stdio / JSON-RPC—→  froggy-sre  ←—socket (primary) / HTTPS (fallback)—→  Froggy / Anthropic
```

## Tools

| Tool | What it does |
|---|---|
| `froggy_status` | Daemon status: model loaded, memory pressure, audio devices, transcription state |
| `froggy_context` | Latest OCR snapshot of your screen — what's open right now |
| `froggy_generate` | Generate via local LLM (private, no cloud) |
| `froggy_transcript` | Transcript of the current or last call (markdown, with timestamps) |

## Requirements

- macOS 14+
- [Froggy daemon](https://github.com/froggychips/Froggy) running

## Install

```bash
# 1. Build the binary
git clone https://github.com/froggychips/froggy-mcp
cd froggy-mcp
swift build -c release
cp .build/release/froggy-mcp /usr/local/bin/froggy-mcp

# 2. Register with Claude Code
claude mcp add froggy /usr/local/bin/froggy-mcp --scope global
```

After restarting Claude Code the four `froggy_*` tools will be available in every session.

## Configuration

Connects to `~/Library/Application Support/Froggy/froggy.sock` by default.  
Override: `FROGGY_IPC_SOCKET=/path/to/froggy.sock`.

## How it works

`froggy-mcp` is a minimal Swift binary — no external dependencies. It speaks
[MCP](https://spec.modelcontextprotocol.io/) (JSON-RPC 2.0 over stdio) toward Claude Code and
speaks Froggy's Unix-socket IPC toward the daemon. The bridge is ~350 lines of Swift.

```
Claude Code  ←—stdio / JSON-RPC—→  froggy-mcp  ←—unix socket / JSON-line—→  Froggy daemon
```

---
*Part of the [Froggy](https://github.com/froggychips/Froggy) ecosystem.*
