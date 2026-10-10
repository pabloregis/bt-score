// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ScoreEngine",
    platforms: [.watchOS(.v10), .macOS(.v14)],
    products: [
        .library(name: "ScoreEngine", targets: ["ScoreEngine"]),
    ],
    targets: [
        .target(name: "ScoreEngine"),
        .testTarget(name: "ScoreEngineTests", dependencies: ["ScoreEngine"]),
    ]
)
