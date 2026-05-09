# froggy-mcp

MCP-сервер для [Froggy](https://github.com/froggychips/Froggy) — даёт Claude Code доступ к локальному контексту твоего Mac.

## Что это

Froggy видит твой экран, слышит созвоны, запускает локальный LLM на 8 GB RAM. Claude Code — мощная облачная модель, но слепая. froggy-mcp соединяет их: Claude Code получает инструменты для обращения к Froggy без copy-paste.

## Инструменты

| Инструмент | Что делает |
|---|---|
| `froggy_status` | Статус daemon: модель, давление памяти, аудио-устройства |
| `froggy_context` | Последний OCR-снапшот экрана — что сейчас открыто |
| `froggy_generate` | Генерация через локальный LLM (приватно, без облака) |
| `froggy_transcript` | Транскрипт текущего или последнего созвона |

## Установка

```bash
# 1. Собрать бинарь
git clone https://github.com/froggychips/froggy-mcp
cd froggy-mcp
swift build -c release
cp .build/release/froggy-mcp /usr/local/bin/froggy-mcp

# 2. Добавить в Claude Code
claude mcp add froggy /usr/local/bin/froggy-mcp
```

## Требования

- macOS 14+
- [Froggy daemon](https://github.com/froggychips/Froggy) запущен

## Конфигурация

По умолчанию подключается к `~/Library/Application Support/Froggy/froggy.sock`.
Переопределить: `FROGGY_IPC_SOCKET=/path/to/froggy.sock`.
