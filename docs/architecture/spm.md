# Swift Package Manager

The layers and features of the application are split into local Swift packages. A package can import only the packages declared in its manifest, so the architecture described in [Clean Architecture](clean-architecture.md) is enforced by the compiler.

## Repository Structure

The Xcode project contains only the application target and the widget extension. Every other piece of code lives in a local package.

```
CoupleWidget.xcodeproj
CoupleWidget/
CoupleWidgetWidget/
Packages/
    Domain/
    DomainFakes/
    Data/
    DesignSystem/
    SharedStorage/
    Features/
        <Name>/
```

Each package has its own `Package.swift`, sources, and tests.

## Packages

### Domain

Entities, repository protocols, use case protocols and their implementations, and errors, organized by business area.
Depends on: `Foundation` only.

### Data

Repository implementations, data transfer objects, the Supabase client configuration, and the connectivity monitor.
Depends on: `Domain`, `SharedStorage`, `Supabase`.

### DomainFakes

Fake implementations of repository and use case protocols, together with sample entities. They are used by previews and tests.
Depends on: `Domain`.

### DesignSystem

The visual foundation of the application and the widget.

- `Theme` contains colors, typography, spacing, and corner radii. Colors live in an asset catalog with light and dark variants.
- `Components` contains reusable views such as buttons, cards, input fields, and empty states.
- `Resources` contains the asset catalog and fonts.

Components accept plain values and closures, never domain entities.
Depends on: `SwiftUI` only.

### SharedStorage

Data shared between the application and the widget through the App Group container and the shared Keychain.
Depends on: `Foundation` only.

### Features

One package per feature. A feature package contains only presentation code: views, view models, routes, and outputs.
Depends on: `Domain`, `DomainFakes`, `DesignSystem`.

### Application Target

The composition root, the application entry point, and the router.
Depends on: all packages.

### Widget Extension

The widget timeline provider, the widget push handler, and the widget views.
Depends on: `SharedStorage`, `DesignSystem`.

## Dependency Graph

```
                    Application
     ┌──────────┬────────┼──────────┬──────────────┐
     ▼          ▼        ▼          ▼              ▼
 Features   DomainFakes Data   DesignSystem   SharedStorage
     │          │        │                         ▲
     │          │        └─────────────────────────┤
     ▼          ▼        ▼                         │
   ────────── Domain ──────────                    │
                                                   │
 Widget ──▶ DesignSystem, SharedStorage ───────────┘
```

## Package Boundaries

- Only the application target imports `Data`.
- Feature packages never import other feature packages.
- Feature packages reference `DomainFakes` only inside `#Preview` blocks.
- The widget extension never imports `Domain`, `Data`, or any feature.
- `DesignSystem` and `SharedStorage` never import `Domain`.

## Access Control

- Types and members that form a package's interface are `public`.
- Everything else keeps the default `internal` access level.

## Actor Isolation

- `DesignSystem` and all feature packages use `MainActor` as their default isolation.
- `Domain`, `DomainFakes`, `Data`, and `SharedStorage` use the default `nonisolated` setting.

## Third-Party Dependencies

- A third-party package is declared only in the manifest of the package that uses it.
- Versions are pinned, and every `Package.resolved` is committed.

## Package Manifests

### Domain

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
    ],
    targets: [
        .target(name: "Domain"),
        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
    ]
)
```

### Data

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Data",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "Data", targets: ["Data"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../SharedStorage"),
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                "SharedStorage",
                .product(name: "Supabase", package: "supabase-swift"),
            ]
        ),
        .testTarget(name: "DataTests", dependencies: ["Data"]),
    ]
)
```

### Feature

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MessageFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "MessageFeature", targets: ["MessageFeature"]),
    ],
    dependencies: [
        .package(path: "../../Domain"),
        .package(path: "../../DomainFakes"),
        .package(path: "../../DesignSystem"),
    ],
    targets: [
        .target(
            name: "MessageFeature",
            dependencies: ["Domain", "DomainFakes", "DesignSystem"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "MessageFeatureTests",
            dependencies: ["MessageFeature", "DomainFakes"]
        ),
    ]
)
```

## Adding a Feature

1. Create the package in `Packages/Features/<Name>` with the `<Name>Feature` library.
2. Declare dependencies on `Domain`, `DomainFakes`, and `DesignSystem`, and set `MainActor` as the default isolation.
3. Add the `<Name>FeatureTests` test target.
4. Add the package to the Xcode project and link the library to the application target.
5. Add a factory method for the feature to `AppContainer`.
6. Register the feature's routes and outputs in the router.

## Naming

- Package folders are named after their purpose: `Domain`, `Data`, `Features/<Name>`.
- Feature packages, products, and targets are named `<Name>Feature`.
- Test targets are named after the target they test with the `Tests` suffix.
- Each file contains one primary type and is named after it.
