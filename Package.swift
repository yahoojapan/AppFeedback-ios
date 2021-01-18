// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AppFeedback",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "AppFeedback", targets: ["AppFeedback"])
    ],
    targets: [
        .target(name: "AppFeedback", path: "AppFeedback")
    ]
)
