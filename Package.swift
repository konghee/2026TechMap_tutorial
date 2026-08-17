// swift-tools-version: 5.9
// RoomAquarium 튜토리얼 카탈로그를 담는 최소 패키지입니다.
// swift-docc-plugin을 통해 GitHub Pages용 정적 문서를 빌드합니다.
import PackageDescription

let package = Package(
    name: "RoomAquarium",
    products: [
        .library(name: "RoomAquarium", targets: ["RoomAquarium"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0")
    ],
    targets: [
        .target(name: "RoomAquarium")
    ]
)
