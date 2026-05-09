// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FroggyMCP",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "froggy-mcp", targets: ["FroggyMCPServer"])
    ],
    targets: [
        .executableTarget(
            name: "FroggyMCPServer",
            path: "Sources/FroggyMCPServer"
        )
    ]
)
