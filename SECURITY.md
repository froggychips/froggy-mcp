# Security Policy

## Supported Versions

Security updates are only provided for the current `main` branch.

## Reporting a Vulnerability

**Do not open a public issue.** Please report security vulnerabilities privately:

- **Telegram:** [@froggychips](https://t.me/froggychips)
- **Email:** big@froggychips.xyz

Include: macOS version, Claude Code version, reproduction steps, and what data was exposed or what action was possible.

## Threat Model

### What this bridge does

`froggy-mcp` is a local stdio↔Unix-socket bridge. Claude Code (running with cloud connectivity) calls `froggy_context` or `froggy_transcript` tools, which are forwarded over a local Unix socket to the Froggy daemon and the result is returned to Claude. No data leaves the device through this bridge — the outbound path to Anthropic's API is owned by Claude Code, not by this bridge.

### Primary threats

1. **IPC socket hijacking** — a malicious process under the same UID creates or replaces the socket at `FROGGY_IPC_SOCKET` before the Froggy daemon does, causing the bridge to connect to the attacker's process instead of Froggy. The attacker can then return fabricated context to Claude.

2. **Screen content sensitivity** — `froggy_context` returns a full OCR snapshot of the screen. If Claude Code sends this to a malicious MCP server or if the tool is invoked in an unintended context, the full screen contents (including other application windows) are exposed to the LLM.

3. **Audio transcript sensitivity** — `froggy_transcript` returns audio transcription output. If a sensitive conversation is in progress when the tool is called, its content reaches the LLM context.

### In scope

- `FROGGY_IPC_SOCKET` path override leading to socket hijacking or MITM between bridge and Froggy daemon
- `froggy_context` tool exposing unredacted screen content to an unintended recipient
- `froggy_transcript` tool exposing audio transcript content to an unintended recipient
- A logic error in the bridge that causes it to forward requests to a socket it does not own

### Out of scope

- Compromise of the Froggy daemon itself (report to the Froggy repo)
- Compromise of Claude Code or Anthropic's API (report to Anthropic)
- Supply-chain attacks — this bridge has **zero external Swift dependencies** (pure stdlib + Foundation); there is no dependency graph to compromise
- Network-based attacks — the bridge is purely local (stdio + Unix socket, no listening ports)
- Side-channel attacks on the local MCP transport

## Sensitive Attack Surfaces

### `FROGGY_IPC_SOCKET` — socket path

The bridge connects to the Unix socket path defined by the `FROGGY_IPC_SOCKET` environment variable. If an attacker can set this variable before the bridge starts, they can redirect all tool calls to a socket they control.

Mitigations:
- The Froggy daemon creates the socket with `0600` permissions (owner only)
- Do not set `FROGGY_IPC_SOCKET` from untrusted input (e.g. a `.env` file in an untrusted project)
- Verify socket ownership before connecting (hardening opportunity — not yet implemented)

### `froggy_context` — full screen OCR

This tool returns the current screen content as OCR text, including content from all visible windows. It does not filter by application. If called in the wrong context, it can expose:
- Passwords visible on screen (e.g. in a terminal or password manager)
- Content from other applications not related to the current task
- Partially redacted secrets (Redactor runs in Froggy, not in this bridge)

Recommendation: restrict `froggy_context` using `allowedTools` in `.claude/settings.json` so it is only active in projects that explicitly need it.

### `froggy_transcript` — audio content

This tool returns transcription of recent audio input. If the device microphone was picking up a sensitive conversation, that content reaches the LLM. The bridge has no awareness of what the microphone captured.

Recommendation: use `allowedTools` to restrict `froggy_transcript` to sessions where audio context is intentionally desired.

### IPC socket permissions

The bridge does not currently authenticate the Froggy daemon — it trusts whatever process is listening on the socket path. This is safe under the assumption that the socket is owned by the same user and has `0600` permissions. A future improvement would be to verify the socket peer's process identity (using `getpeercred` or similar) before sending tool requests.

## Privacy Notes

- **No data leaves the device through this bridge.** The bridge is a local forwarder; it does not open any network connections. Data sent to Anthropic's API travels through Claude Code's own transport, which the user controls.
- **The bridge is stateless and logs nothing.** No screen content, audio transcripts, or tool arguments are written to disk by this bridge.
- **Redaction happens in Froggy, not here.** If Froggy's `Redactor` misses a secret in the OCR output, the bridge will forward it as-is. The bridge has no knowledge of what constitutes sensitive content.

## Known Limitations

- **No authentication between Claude Code and the bridge.** Any MCP client that can launch the bridge binary can call `froggy_context` and receive screen content. Use `allowedTools` in `.claude/settings.json` to restrict which projects and sessions can invoke these tools.
- **Socket peer not verified.** The bridge connects to whichever process is listening on `FROGGY_IPC_SOCKET`. If the socket is replaced by another process before the bridge connects, the bridge cannot detect this.
- **Screen content is unfiltered at the bridge layer.** `froggy_context` returns everything Froggy's OCR captured. Filtering must be configured in Froggy itself (via Redactor patterns) or in Claude's system prompt.

## Response SLA

| Severity | Example | Target response |
|---|---|---|
| Critical | Socket hijack enabling MITM of all tool calls | Patch within 48 h |
| High | Screen content leaked to unintended MCP client | Patch within 7 days |
| Medium | Socket permission misconfiguration | Patch within 14 days |
| Low | Docs / hardening gaps | Best effort |
