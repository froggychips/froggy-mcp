// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FroggyMCP",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "froggy-mcp", targets: ["FroggyMCPServer"])
    ],
    dependencies: [
        .package(url: "https://github.com/froggychips/FroggyKit", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "FroggyMCPServer",
            dependencies: [.product(name: "FroggyKit", package: "FroggyKit")],
            path: "Sources/FroggyMCPServer"
        ),
        .testTarget(
            name: "FroggyMCPTests",
            dependencies: ["FroggyMCPServer"],
            path: "Tests/FroggyMCPTests"
        )
    ]
)
