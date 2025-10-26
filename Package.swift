// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TimeDonut",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "TimeDonut",
            targets: ["TimeDonut"]
        )
    ],
    dependencies: [
        // No external dependencies - using custom OAuth 2.0 implementation and URLSession for API calls
    ],
    targets: [
        .executableTarget(
            name: "TimeDonut",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "TimeDonutTests",
            dependencies: ["TimeDonut"],
            path: "Tests"
        )
    ]
)
