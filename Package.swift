// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Eyedropper",
    platforms: [.macOS(.v14)],
    products: [
        // A droplet is a loadable bundle, so its product is a dynamic library.
        // Do not make it static: the app already carries DroppyKit, and a
        // second copy inside the droplet gives the same type two metadata
        // records, which fails every cast between them.
        .library(name: "Eyedropper", type: .dynamic, targets: ["Eyedropper"])
    ],
    dependencies: [
        .package(url: "https://gitlab.com/droppyformac1/droppykit.git", from: "1.6.0")
    ],
    targets: [
        .target(
            name: "Eyedropper",
            dependencies: [.product(name: "DroppyKit", package: "droppykit")]
        ),
        .executableTarget(
            name: "EyedropperHarness",
            dependencies: [
                "Eyedropper",
                .product(name: "DroppyKitHarness", package: "droppykit")
            ]
        )
    ]
)