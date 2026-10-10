// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ScoreEngine",
    platforms: [.watchOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "ScoreEngine", targets: ["ScoreEngine"]),
    ],
    targets: [
        .target(name: "ScoreEngine"),
        .testTarget(name: "ScoreEngineTests", dependencies: ["ScoreEngine"]),
    ]
)
