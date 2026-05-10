import Foundation
import FroggyKit

// MARK: - MCP JSON-RPC сервер (stdio transport)
//
// Claude Code запускает этот бинарь и общается через stdin/stdout.
// Протокол: JSON-RPC 2.0, по одному объекту на строку.

let client = FroggyClient()

while let line = readLine(strippingNewline: true) {
    guard !line.isEmpty,
          let data = line.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { continue }

    let id = json["id"]
    let method = json["method"] as? String ?? ""
    let params = json["params"] as? [String: Any] ?? [:]

    if let response = handle(method: method, params: params, id: id) {
        writeJSON(response)
    }
}

// MARK: - Dispatch

func handle(method: String, params: [String: Any], id: Any?) -> [String: Any]? {
    switch method {
    case "initialize":
        return ok(id: id, result: [
            "protocolVersion": "2024-11-05",
            "capabilities": ["tools": [:] as [String: Any]],
            "serverInfo": ["name": "froggy-mcp", "version": "0.1.0"]
        ])

    case "notifications/initialized":
        return nil // no response for notifications

    case "ping":
        return ok(id: id, result: [:] as [String: Any])

    case "tools/list":
        return ok(id: id, result: ["tools": toolDefinitions()])

    case "tools/call":
        let name = params["name"] as? String ?? ""
        let arguments = params["arguments"] as? [String: Any] ?? [:]
        let content = callTool(name: name, arguments: arguments, client: client)
        return ok(id: id, result: ["content": content])

    default:
        return err(id: id, code: -32601, message: "Method not found: \(method)")
    }
}

// MARK: - Response builders

func ok(id: Any?, result: [String: Any]) -> [String: Any] {
    var r: [String: Any] = ["jsonrpc": "2.0", "result": result]
    if let id { r["id"] = id }
    return r
}

func err(id: Any?, code: Int, message: String) -> [String: Any] {
    var r: [String: Any] = ["jsonrpc": "2.0",
                            "error": ["code": code, "message": message]]
    if let id { r["id"] = id }
    return r
}

func writeJSON(_ obj: [String: Any]) {
    guard let data = try? JSONSerialization.data(withJSONObject: obj),
          var line = String(data: data, encoding: .utf8)
    else { return }
    line += "\n"
    FileHandle.standardOutput.write(Data(line.utf8))
}
