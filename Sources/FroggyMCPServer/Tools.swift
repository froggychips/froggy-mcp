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
        ],
        [
            "name": "froggy_speak",
            "description": "Froggy произносит текст вслух через системный TTS. Используй чтобы дать голосовой ответ пользователю. Блокирует до конца речи.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "text": [
                        "type": "string",
                        "description": "Текст для озвучки"
                    ],
                    "voice": [
                        "type": "string",
                        "description": "Голос macOS (say -v). По умолчанию Milena (Enhanced). Примеры: Samantha (en), Daniel (en-GB)."
                    ]
                ] as [String: Any],
                "required": ["text"]
            ]
        ],
        [
            "name": "froggy_freeze",
            "description": "Замораживает приложение (SIGSTOP) чтобы освободить unified memory. Передай bundle_id (com.spotify.client) или имя из froggy_status. Используй перед тяжёлыми задачами — LLM, билд, деплой.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "bundle_id": [
                        "type": "string",
                        "description": "Bundle ID приложения, например com.spotify.client, com.tinyspeck.slackmacgap, com.hnc.Discord"
                    ]
                ] as [String: Any],
                "required": ["bundle_id"]
            ]
        ],
        [
            "name": "froggy_thaw_all",
            "description": "Размораживает все приложения (SIGCONT). Вызывай после завершения тяжёлой задачи.",
            "inputSchema": [
                "type": "object",
                "properties": [:] as [String: Any]
            ]
        ],
        [
            "name": "froggy_pressure",
            "description": "Текущее давление памяти и список замороженных процессов. Используй чтобы решить нужно ли замораживать приложения.",
            "inputSchema": [
                "type": "object",
                "properties": [:] as [String: Any]
            ]
        ],
        [
            "name": "froggy_listen",
            "description": "Запускает запись созвона (транскрипция микрофона). Опционально инжектирует pre-call контекст (Jira-тикеты, заметки) прямо при старте. Возвращает путь к файлу сессии.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "inject_text": [
                        "type": "string",
                        "description": "Pre-call контекст для инжекта в сессию (например содержимое Jira-тикетов)"
                    ],
                    "inject_title": [
                        "type": "string",
                        "description": "Заголовок для inject_text (default: Pre-call Context)"
                    ]
                ] as [String: Any]
            ]
        ],
        [
            "name": "froggy_listen_stop",
            "description": "Останавливает запись созвона. Возвращает путь к файлу сессии — используй froggy_recap чтобы сгенерировать резюме.",
            "inputSchema": [
                "type": "object",
                "properties": [:] as [String: Any]
            ]
        ],
        [
            "name": "froggy_recap",
            "description": "Генерирует LLM-резюме последнего созвона через локальную модель. Дописывает summary в markdown-файл сессии. Занимает до 60 секунд.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "path": [
                        "type": "string",
                        "description": "Путь к файлу сессии (default: последняя сессия)"
                    ]
                ] as [String: Any]
            ]
        ],
        [
            "name": "froggy_inject",
            "description": "Инжектирует текст в markdown-файл текущего созвона. Используй чтобы добавить Jira-тикеты, заметки или любой контекст в сессию до или во время созвона — локальный LLM увидит это в транскрипте.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "text": [
                        "type": "string",
                        "description": "Текст для инжекта в сессию созвона"
                    ],
                    "title": [
                        "type": "string",
                        "description": "Заголовок секции (default: Injected Context)"
                    ]
                ] as [String: Any],
                "required": ["text"]
            ]
        ],
        [
            "name": "froggy_chat",
            "description": "Быстрый голосовой ответ через локальный LLM без roundtrip в Claude API. Pipeline: берёт хвост транскрипта → froggy_generate → froggy_speak (Milena Enhanced). Latency ~1-2с. Используй вместо froggy_generate+froggy_speak для голосового диалога в реальном времени.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "question": [
                        "type": "string",
                        "description": "Вопрос или реплика. Если не задан — отвечает на последнее из транскрипта."
                    ],
                    "max_transcript_chars": [
                        "type": "integer",
                        "description": "Сколько символов хвоста транскрипта брать как контекст (default 800)"
                    ],
                    "max_tokens": [
                        "type": "integer",
                        "description": "Максимум токенов ответа локального LLM (default 120)"
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
        case "froggy_speak":
            guard let speakText = arguments["text"] as? String else {
                return errorContent("missing required argument: text")
            }
            let voice = arguments["voice"] as? String
            text = try handleSpeak(text: speakText, voice: voice, client: client)
        case "froggy_freeze":
            guard let bundleId = arguments["bundle_id"] as? String else {
                return errorContent("missing required argument: bundle_id")
            }
            text = try handleFreeze(bundleId: bundleId, client: client)
        case "froggy_thaw_all":
            text = try handleThawAll(client: client)
        case "froggy_pressure":
            text = try handlePressure(client: client)
        case "froggy_listen":
            let injectText  = arguments["inject_text"]  as? String
            let injectTitle = arguments["inject_title"] as? String
            text = try handleListen(injectText: injectText, injectTitle: injectTitle, client: client)
        case "froggy_listen_stop":
            text = try handleListenStop(client: client)
        case "froggy_recap":
            let path = arguments["path"] as? String
            text = try handleRecap(path: path, client: client)
        case "froggy_transcript":
            let maxChars = arguments["max_chars"] as? Int ?? 8000
            text = try handleTranscript(maxChars: maxChars, client: client)
        case "froggy_inject":
            guard let injectText = arguments["text"] as? String else {
                return errorContent("missing required argument: text")
            }
            let title = arguments["title"] as? String
            text = try handleInject(text: injectText, title: title, client: client)
        case "froggy_chat":
            let question = arguments["question"] as? String
            let maxTranscriptChars = arguments["max_transcript_chars"] as? Int ?? 800
            let maxTokens = arguments["max_tokens"] as? Int ?? 120
            text = try handleChat(question: question, maxTranscriptChars: maxTranscriptChars,
                                  maxTokens: maxTokens, client: client)
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

private func handleSpeak(text: String, voice: String?, client: FroggyClient) throws -> String {
    var req = FroggyRequest(cmd: "speak", prompt: text)
    req.path = voice ?? "Milena (Enhanced)"
    let responses = try client.send(req, timeoutSeconds: 120)
    if let err = responses.first(where: { $0.ok == false })?.error {
        throw MCPToolError(err)
    }
    return "произнесено"
}

private func handleFreeze(bundleId: String, client: FroggyClient) throws -> String {
    var req = FroggyRequest(cmd: "freeze")
    req.path = bundleId
    let responses = try client.send(req)
    if let err = responses.first(where: { $0.ok == false })?.error {
        throw MCPToolError(err)
    }
    return "заморожено: \(bundleId)"
}

private func handleThawAll(client: FroggyClient) throws -> String {
    let responses = try client.send(FroggyRequest(cmd: "thawAll"))
    if let err = responses.first(where: { $0.ok == false })?.error {
        throw MCPToolError(err)
    }
    return "все приложения разморожены"
}

private func handlePressure(client: FroggyClient) throws -> String {
    let responses = try client.send(FroggyRequest(cmd: "pressure"))
    guard let r = responses.first else { return "нет ответа" }
    if let err = r.error { throw MCPToolError(err) }
    var lines: [String] = []
    lines.append("давление памяти: \(r.pressureLevel ?? "unknown")")
    if let t1 = r.tier1Frozen, !t1.isEmpty { lines.append("tier-1 заморожено (pids): \(t1.map(String.init).joined(separator: ", "))") }
    if let t2 = r.tier2Frozen, !t2.isEmpty { lines.append("tier-2 заморожено (pids): \(t2.map(String.init).joined(separator: ", "))") }
    if let secs = r.secondsInLevel { lines.append("в этом уровне: \(secs)с") }
    return lines.joined(separator: "\n")
}

private func handleListen(injectText: String?, injectTitle: String?, client: FroggyClient) throws -> String {
    var req = FroggyRequest(cmd: "listen")
    // pre-call inject: write to temp file, daemon reads it via request.path
    if let text = injectText, !text.isEmpty {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("froggy-inject-\(Int(Date().timeIntervalSince1970)).md")
        try text.write(to: tmp, atomically: true, encoding: .utf8)
        req.path = tmp.path
        req.accessor = injectTitle ?? "Pre-call Context"
    }
    let responses = try client.send(req)
    if let err = responses.first(where: { $0.ok == false })?.error {
        throw MCPToolError(err)
    }
    let r = responses.first
    var parts = ["слушаю: \(r?.listening == true ? "да" : "нет")"]
    if let url = r?.sessionURL { parts.append("сессия: \(url)") }
    if injectText != nil { parts.append("контекст инжектирован") }
    return parts.joined(separator: "\n")
}

private func handleListenStop(client: FroggyClient) throws -> String {
    let responses = try client.send(FroggyRequest(cmd: "listenStop"))
    if let err = responses.first(where: { $0.ok == false })?.error {
        throw MCPToolError(err)
    }
    let r = responses.first
    var parts = ["запись остановлена"]
    if let url = r?.sessionURL {
        parts.append("сессия: \(url)")
        parts.append("резюме: froggy_recap")
    }
    return parts.joined(separator: "\n")
}

private func handleRecap(path: String?, client: FroggyClient) throws -> String {
    var req = FroggyRequest(cmd: "recap")
    req.path = path
    let result = try client.call(req, timeout: 120)
    return result.isEmpty ? "(пустое резюме)" : result
}

private func handleChat(question: String?, maxTranscriptChars: Int, maxTokens: Int,
                        client: FroggyClient) throws -> String {
    // 1. Tail of transcript (if session active)
    var transcriptSlice = ""
    if let sessionPath = (try? client.send(FroggyRequest(cmd: "listenStatus")))?.first?.sessionURL,
       let content = try? String(contentsOfFile: sessionPath, encoding: .utf8) {
        transcriptSlice = String(content.suffix(maxTranscriptChars))
    }

    // 2. Build a slim prompt
    let persona = """
        Ты — Froggy, голосовой ассистент. Говоришь живо и по-человечески, без канцелярита. \
        Отвечаешь на том же языке что и вопрос. Максимум 2 предложения — чётко и тепло.
        """
    let prompt: String
    if let q = question, !q.isEmpty {
        prompt = transcriptSlice.isEmpty
            ? "\(persona)\n\nВопрос: \(q)"
            : "\(persona)\n\nКонтекст разговора:\n\(transcriptSlice)\n\nВопрос: \(q)"
    } else if !transcriptSlice.isEmpty {
        prompt = "\(persona)\n\nПоследние реплики:\n\(transcriptSlice)\n\nОтветь на последнее сообщение."
    } else {
        return "нет транскрипта и вопроса"
    }

    // 3. Generate via local LLM
    let reply = try client.call(
        FroggyRequest(cmd: "generate", prompt: prompt, maxTokens: maxTokens),
        timeout: 60
    )
    guard !reply.isEmpty else { return "пустой ответ от LLM" }

    // 4. Speak
    var speakReq = FroggyRequest(cmd: "speak", prompt: reply)
    speakReq.path = "Milena (Enhanced)"
    _ = try? client.send(speakReq, timeoutSeconds: 120)

    return reply
}

private func handleInject(text: String, title: String?, client: FroggyClient) throws -> String {
    var req = FroggyRequest(cmd: "injectContext", prompt: text)
    req.accessor = title
    let responses = try client.send(req)
    if let err = responses.first(where: { $0.ok == false })?.error {
        throw MCPToolError(err)
    }
    return "контекст добавлен в сессию\(title.map { ": \($0)" } ?? "")"
}

private func errorContent(_ message: String) -> [[String: Any]] {
    [["type": "text", "text": "Ошибка: \(message)"]]
}
