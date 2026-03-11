// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "clipboard",
    platforms: [
        .macOS(.v13),
    ],
    targets: [
        .executableTarget(
            name: "clipboard"
        ),
        .testTarget(
            name: "clipboardTests",
            dependencies: ["clipboard"]
        ),
    ]
)
