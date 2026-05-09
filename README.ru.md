# froggy-mcp 🐸

🌐 [English](README.md) · **Русский**

> **MCP-сервер, который даёт Claude Code доступ к локальному контексту Froggy — экрану, созвонам, локальному LLM.**

[Froggy](https://github.com/froggychips/Froggy) работает на твоём Mac: видит экран через OCR,
транскрибирует созвоны, запускает локальный LLM на 8 ГБ RAM. Claude Code — мощная облачная
модель, но слепая. `froggy-mcp` соединяет их — Claude обращается к Froggy через Unix-сокет
без какого-либо copy-paste.

**Статус:** персональный companion к Froggy. Не продукт. Требует запущенного
[Froggy daemon](https://github.com/froggychips/Froggy).

📬 Контакт: [@froggychips](https://t.me/froggychips) в Telegram
📜 Лицензия: [MIT](LICENSE)

---

## Инструменты

| Инструмент | Что делает |
|---|---|
| `froggy_status` | Статус daemon: модель загружена, давление памяти, аудио-устройства, идёт ли транскрипция |
| `froggy_context` | Последний OCR-снапшот экрана — что сейчас открыто |
| `froggy_generate` | Генерация через локальный LLM (приватно, без облака) |
| `froggy_transcript` | Транскрипт текущего или последнего созвона (markdown, с временными метками) |

## Требования

- macOS 14+
- Запущенный [Froggy daemon](https://github.com/froggychips/Froggy)

## Установка

```bash
# 1. Собрать бинарь
git clone https://github.com/froggychips/froggy-mcp
cd froggy-mcp
swift build -c release
cp .build/release/froggy-mcp /usr/local/bin/froggy-mcp

# 2. Зарегистрировать в Claude Code
claude mcp add froggy /usr/local/bin/froggy-mcp --scope global
```

После перезапуска Claude Code четыре `froggy_*` инструмента будут доступны в каждой сессии.

## Конфигурация

По умолчанию подключается к `~/Library/Application Support/Froggy/froggy.sock`.  
Переопределить: `FROGGY_IPC_SOCKET=/path/to/froggy.sock`.

## Как работает

`froggy-mcp` — минимальный Swift-бинарь без внешних зависимостей. Говорит
[MCP](https://spec.modelcontextprotocol.io/) (JSON-RPC 2.0 через stdio) в сторону Claude Code
и Froggy Unix-socket IPC в сторону daemon. Весь bridge — ~350 строк Swift.

```
Claude Code  ←—stdio / JSON-RPC—→  froggy-mcp  ←—unix socket / JSON-line—→  Froggy daemon
```
