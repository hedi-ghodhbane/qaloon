// swift-tools-version:5.9
import PackageDescription

// Headless checks of the Qaloon app's recitation follower, on recordings instead of a
// microphone. The follower's sources are links into the app: what is tested is what ships.
//   replay  the follower over saved hypotheses; must time the words as prototype/follow.py did
//   pages   the reader view's hide-mode flow (covers, page turns, a start mid-page)
//   stream  the whole pipeline - WhisperKit with the Core ML model, then the follower - on a wav
let package = Package(
    name: "ReciteHarness",
    platforms: [.macOS(.v14)],
    dependencies: [.package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "1.1.0")],
    targets: [
        .executableTarget(name: "replay"),
        .executableTarget(name: "pages"),
        .executableTarget(name: "stream", dependencies: [.product(name: "WhisperKit", package: "WhisperKit")]),
    ]
)
