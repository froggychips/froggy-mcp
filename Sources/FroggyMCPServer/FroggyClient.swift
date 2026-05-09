import Darwin
import Foundation

// Минимальные типы Froggy IPC wire-формата.

struct FroggyRequest: Codable {
    var cmd: String
    var prompt: String?
    var maxTokens: Int?
    var maxChars: Int?
    var useContext: Bool?
    var path: String?
    var accessor: String?
}

struct FroggyResponse: Codable {
    var ok: Bool?
    var error: String?
    var text: String?
    var context: String?
    var listening: Bool?
    var sessionURL: String?
    var audioOutputDevice: String?
    var audioInputDevice: String?
    var modelLoaded: Bool?
    var modelPath: String?
    var memoryPressure: Int?
    var snapshots: Int?
    var kvCacheBits: Int?
    var pressureLevel: String?
    var tier1Frozen: [Int32]?
    var tier2Frozen: [Int32]?
    var secondsInLevel: Int?
    var `final`: Bool?
}

enum FroggyClientError: Error, CustomStringConvertible {
    case socketCreation
    case connection(Int32)
    case daemonNotRunning
    case timeout

    var description: String {
        switch self {
        case .socketCreation:       return "не удалось создать сокет"
        case .connection(let e):    return "не удалось подключиться к daemon: errno=\(e)"
        case .daemonNotRunning:     return "Froggy daemon не запущен (проверь: launchctl list | grep froggy)"
        case .timeout:              return "timeout ожидания ответа от daemon"
        }
    }
}

/// Синхронный клиент к Froggy daemon через unix-socket.
/// Один запрос → ждёт все чанки до final=true → возвращает массив.
struct FroggyClient {
    let socketPath: String

    init() {
        socketPath = ProcessInfo.processInfo.environment["FROGGY_IPC_SOCKET"]
            ?? (FileManager.default.homeDirectoryForCurrentUser.path
                + "/Library/Application Support/Froggy/froggy.sock")
    }

    /// Отправляет запрос, собирает все response-чанки до final=true.
    func send(_ request: FroggyRequest, timeoutSeconds: Double = 30) throws -> [FroggyResponse] {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw FroggyClientError.socketCreation }
        defer { close(fd) }

        // SO_RCVTIMEO + SO_SNDTIMEO
        let secs = Int(timeoutSeconds)
        let usecs = Int32((timeoutSeconds - Double(secs)) * 1_000_000)
        var tv = timeval(tv_sec: secs, tv_usec: usecs)
        withUnsafePointer(to: &tv) { ptr in
            _ = setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, ptr, socklen_t(MemoryLayout<timeval>.size))
            _ = setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, ptr, socklen_t(MemoryLayout<timeval>.size))
        }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let maxLen = MemoryLayout.size(ofValue: addr.sun_path)
        socketPath.withCString { cStr in
            withUnsafeMutablePointer(to: &addr.sun_path) { sunPath in
                sunPath.withMemoryRebound(to: CChar.self, capacity: maxLen) { dst in
                    _ = strlcpy(dst, cStr, maxLen)
                }
            }
        }
        let connectResult = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                Darwin.connect(fd, sockPtr, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard connectResult == 0 else {
            throw errno == ENOENT || errno == ECONNREFUSED
                ? FroggyClientError.daemonNotRunning
                : FroggyClientError.connection(errno)
        }

        var data = try JSONEncoder().encode(request)
        data.append(0x0A)
        _ = data.withUnsafeBytes { Darwin.send(fd, $0.baseAddress, data.count, 0) }

        var buffer = Data()
        var responses: [FroggyResponse] = []
        let chunk = Data(count: 4096)
        while true {
            var mutable = chunk
            let n = mutable.withUnsafeMutableBytes {
                Darwin.recv(fd, $0.baseAddress, 4096, 0)
            }
            if n <= 0 { break }
            buffer.append(mutable.prefix(n))
            while let nl = buffer.firstIndex(of: 0x0A) {
                let line = buffer[buffer.startIndex..<nl]
                buffer.removeSubrange(buffer.startIndex...nl)
                if let r = try? JSONDecoder().decode(FroggyResponse.self, from: line) {
                    responses.append(r)
                    if r.final == true { return responses }
                }
            }
        }
        return responses
    }

    /// Удобный хелпер: один запрос, склеивает text-чанки, бросает если ok=false.
    func call(_ request: FroggyRequest, timeout: Double = 30) throws -> String {
        let responses = try send(request, timeoutSeconds: timeout)
        if let err = responses.first(where: { $0.ok == false })?.error {
            throw MCPToolError(err)
        }
        return responses.compactMap(\.text).joined()
    }
}

struct MCPToolError: Error, CustomStringConvertible {
    let description: String
    init(_ msg: String) { description = msg }
}
