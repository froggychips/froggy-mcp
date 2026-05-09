import Foundation

// MARK: - Tool definitions (tools/list)

func toolDefinitions() -> [[String: Any]] {
    [
        [
            "name": "froggy_status",
            "description": "Статус Froggy daemon: загружена ли модель, идёт ли транскрипция созвона, давление памяти, подключённые аудио-устройства.",
            "inputSchema": [
                "type": "object",
                "properties": [:] as [String: Any]
            ]
        ],
        [
            "name": "froggy_context",
            "description": "Последний OCR-контекст экрана пользователя. Что сейчас открыто на Mac: код, браузер, документы. Используй чтобы понять с чем работает пользователь без его объяснений.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "max_chars": [
                        "type": "integer",
                        "description": "Максимум символов контекста (default 4000)"
                    ]
                ] as [String: Any]
            ]
        ],
        [
            "name": "froggy_generate",
            "description": "Генерирует ответ через локальный LLM на Mac пользователя. Используй для приватных вопросов или когда нужно спросить о локальном контексте.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "prompt": [
                        "type": "string",
                        "description": "Промпт для локального LLM"
                    ],
                    "max_tokens": [
                        "type": "integer",
                        "description": "Максимум токенов ответа (default 200)"
                    ],
                    "use_context": [
                        "type": "boolean",
                        "description": "Добавить OCR-контекст экрана в промпт (default false)"
                    ]
                ] as [String: Any],
                "required": ["prompt"]
            ]
        ],
        [
            "name": "froggy_transcript",
            "description": "Транскрипт текущего или последнего созвона. Возвращает markdown-файл сессии: кто что говорил, временные метки. Используй чтобы ответить на вопросы о прошедшей встрече.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "max_chars": [
                        "type": "integer",
                        "description": "Максимум символов транскрипта (default 8000)"
                    ]
                ] as [String: Any]
            ]
        ]
    ]
}

// MARK: - Tool handlers

func callTool(name: String, arguments: [String: Any], client: FroggyClient) -> [[String: Any]] {
    do {
        let text: String
        switch name {
        case "froggy_status":
            text = try handleStatus(client: client)
        case "froggy_context":
            let maxChars = arguments["max_chars"] as? Int ?? 4000
            text = try handleContext(maxChars: maxChars, client: client)
        case "froggy_generate":
            guard let prompt = arguments["prompt"] as? String else {
                return errorContent("missing required argument: prompt")
            }
            let maxTokens = arguments["max_tokens"] as? Int ?? 200
            let useContext = arguments["use_context"] as? Bool ?? false
            text = try handleGenerate(prompt: prompt, maxTokens: maxTokens,
                                      useContext: useContext, client: client)
        case "froggy_transcript":
            let maxChars = arguments["max_chars"] as? Int ?? 8000
            text = try handleTranscript(maxChars: maxChars, client: client)
        default:
            return errorContent("unknown tool: \(name)")
        }
        return [["type": "text", "text": text]]
    } catch {
        return errorContent(error.localizedDescription)
    }
}

// MARK: - Individual handlers

private func handleStatus(client: FroggyClient) throws -> String {
    let responses = try client.send(FroggyRequest(cmd: "status"))
    guard let r = responses.first else { return "нет ответа от daemon" }
    var lines: [String] = []
    lines.append("**Froggy status**")
    lines.append("модель загружена: \(r.modelLoaded == true ? "да" : "нет")")
    if let path = r.modelPath { lines.append("модель: \(path)") }
    lines.append("давление памяти: \(r.memoryPressure ?? 0)%")
    lines.append("снапшотов контекста: \(r.snapshots ?? 0)")
    lines.append("транскрипция: \(r.listening == true ? "идёт" : "нет")")
    if let out = r.audioOutputDevice { lines.append("аудио выход: \(out)") }
    if let inp = r.audioInputDevice  { lines.append("аудио вход: \(inp)") }
    if let bits = r.kvCacheBits      { lines.append("KV-cache: \(bits) bit") }
    return lines.joined(separator: "\n")
}

private func handleContext(maxChars: Int, client: FroggyClient) throws -> String {
    let result = try client.call(FroggyRequest(cmd: "context", maxChars: maxChars))
    return result.isEmpty ? "контекст пустой — экран не захвачен или daemon только запустился" : result
}

private func handleGenerate(prompt: String, maxTokens: Int, useContext: Bool,
                             client: FroggyClient) throws -> String {
    let result = try client.call(
        FroggyRequest(cmd: "generate", prompt: prompt, maxTokens: maxTokens, useContext: useContext),
        timeout: 120
    )
    return result.isEmpty ? "(пустой ответ)" : result
}

private func handleTranscript(maxChars: Int, client: FroggyClient) throws -> String {
    // Получаем путь к файлу сессии через listenStatus
    let responses = try client.send(FroggyRequest(cmd: "listenStatus"))
    guard let r = responses.first, let sessionPath = r.sessionURL else {
        return "нет активной или завершённой сессии — запусти `froggy listen` для начала созвона"
    }
    guard let content = try? String(contentsOfFile: sessionPath, encoding: .utf8) else {
        return "файл сессии не читается: \(sessionPath)"
    }
    let trimmed = content.count > maxChars
        ? String(content.prefix(maxChars)) + "\n\n… (обрезано, полный файл: \(sessionPath))"
        : content
    return trimmed
}

private func errorContent(_ message: String) -> [[String: Any]] {
    [["type": "text", "text": "Ошибка: \(message)"]]
}
