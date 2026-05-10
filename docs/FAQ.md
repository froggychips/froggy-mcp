# froggy-mcp — FAQ

Quick answers for Froggy users who want to connect it to Claude Code.

---

## What does froggy-mcp do?

It's a bridge. Claude Code can call tools that run on your machine. This bridge exposes two of Froggy's capabilities as MCP tools:

- **`froggy_context`** — asks Froggy for the current screen snapshot (OCR text, after Redactor strips secrets)
- **`froggy_transcript`** — asks Froggy for recent audio transcription

Flow: Claude Code calls the tool → bridge forwards the request to Froggy over a local Unix socket → Froggy responds → Claude sees your screen content.

---

## Why is this a separate repo from Froggy?

Froggy is a standalone daemon that runs without Claude Code. The MCP bridge is optional and only useful if you're also using Claude Code. Separating them means:

- You can run Froggy without Claude Code (memory management + local LLM still work)
- Claude Code users can add the bridge without pulling in Froggy's full source
- The bridge has zero external Swift dependencies — pure stdlib + Foundation only

---

## Does my screen get sent to Anthropic?

The bridge itself sends nothing anywhere. It's a local forwarder: reads from a Unix socket (Froggy) and writes to stdio (Claude Code).

What happens after that is Claude Code's job — it packages the tool result and sends it to Anthropic's API as part of your conversation. So yes, the OCR text of your screen reaches Anthropic's servers, the same way any message you type does.

If you don't want screen content sent to Anthropic: don't call `froggy_context`, or use `allowedTools` in `.claude/settings.json` to restrict which projects can invoke it.

---

## How do I install it?

The Froggy daemon must be running first.

```bash
git clone https://github.com/froggychips/froggy-mcp
cd froggy-mcp
swift build -c release
```

Then add to your project's `.mcp.json` (or `~/.claude.json` for global access):
```json
{
  "mcpServers": {
    "froggy": {
      "command": "/path/to/froggy-mcp/.build/release/froggy-mcp"
    }
  }
}
```

---

## Does it work without Froggy running?

The bridge process starts, but tool calls will fail with a connection error — there's nothing listening on the socket. Start the Froggy daemon first.

---

## What's the difference between the two tools?

| Tool | Returns | Requires |
|---|---|---|
| `froggy_context` | Screen OCR text (latest snapshot, secrets stripped) | Screen Recording permission |
| `froggy_transcript` | Recent audio transcription | Microphone permission |

Both are processed on-device by Froggy before the bridge ever sees them. The bridge just forwards the result.

---

## Will this slow down Claude Code?

The bridge is a thin stdio↔socket forwarder — negligible overhead. The OCR processing happens in Froggy's background loop regardless of whether the bridge is connected, so there's no extra cost per tool call; Froggy already did the work before you asked.

---

## Can I use only one of the two tools?

Yes. Use `allowedTools` in `.claude/settings.json` to enable only what you need:

```json
{
  "allowedTools": ["mcp__froggy__froggy_context"]
}
```

This keeps `froggy_transcript` out of Claude's available tool list for that project.

---

## Where do I report a bug?

[GitHub Issues](https://github.com/froggychips/froggy-mcp/issues) or Telegram [@froggychips](https://t.me/froggychips).
