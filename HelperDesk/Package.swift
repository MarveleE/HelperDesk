// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HelperDesk",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HelperDesk",
            targets: ["HelperDesk"]),
    ],
    dependencies: [
        .package(url: "https://github.com/longitachi/ZLPhotoBrowser.git", from: Version(stringLiteral: "4.0.0")),
        .package(url: "https://github.com/jdg/MBProgressHUD.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "HelperDesk",
            dependencies: [
                .product(name: "ZLPhotoBrowser", package: "ZLPhotoBrowser"),
                .product(name: "MBProgressHUD", package: "MBProgressHUD"),
                .product(name: "Moya", package: "Moya"),
                .product(name: "SnapKit", package: "SnapKit")
            ]
        ),
        .testTarget(
            name: "HelperDeskTests",
            dependencies: ["HelperDesk"]),
    ]
)
