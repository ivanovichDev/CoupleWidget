// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "NoteCache",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "NoteCache", targets: ["NoteCache"])
    ],
    targets: [
        .target(name: "NoteCache"),
        .testTarget(name: "NoteCacheTests", dependencies: ["NoteCache"])
    ]
)
