// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FroggyMCP",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "froggy-mcp", targets: ["FroggyMCPServer"])
    ],
    dependencies: [
        .package(url: "https://github.com/froggychips/FroggyKit.git", from: "0.3.1")
    ],
    targets: [
        .executableTarget(
            name: "FroggyMCPServer",
            dependencies: [.product(name: "FroggyKit", package: "FroggyKit")],
            path: "Sources/FroggyMCPServer",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny"),
            ]
        ),
        .testTarget(
            name: "FroggyMCPTests",
            dependencies: ["FroggyMCPServer"],
            path: "Tests/FroggyMCPTests"
        )
    ]
)
