// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "Data", targets: ["Data"]),
        .library(name: "WidgetData", targets: ["WidgetData"])
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "Supabase", package: "supabase-swift")
            ]
        ),
        .target(
            name: "WidgetData",
            dependencies: ["Domain"]
        ),
        .testTarget(
            name: "DataTests",
            dependencies: [
                "Data",
                .product(name: "Supabase", package: "supabase-swift")
            ]
        ),
        .testTarget(
            name: "WidgetDataTests",
            dependencies: ["WidgetData", "Domain"]
        )
    ]
)
