// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SpeechMaster",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SpeechMaster",
            targets: ["SpeechMaster"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "0.3.0"),
        .package(url: "https://github.com/google/generative-ai-swift", from: "0.4.0")
    ],
    targets: [
        .target(
            name: "SpeechMaster",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "GoogleGenerativeAI", package: "generative-ai-swift")
            ]),
    ]
) 