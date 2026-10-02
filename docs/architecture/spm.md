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
    Data/
    DesignSystem/
    NoteCache/
    Features/
        <Name>/
```

Each package has its own `Package.swift`, sources, and tests.

## Packages

### Domain

Entities, repository protocols, use case protocols and their implementations, and errors, organized by business area.
Depends on: `Foundation` only.

### Data

Repository implementations, data transfer objects, the Supabase client configuration, and the connectivity monitor. The package has two targets:

- `Data` implements the repositories of the application with the Supabase SDK.
- `WidgetData` implements the repository of the widget with `URLSession` and the anon key, so the widget extension never links the Supabase SDK.

`Data` depends on: `Domain`, `Supabase`. `WidgetData` depends on: `Domain`.

### DesignSystem

The visual foundation of the application and the widget.

- `Theme` contains colors, typography, spacing, and corner radii. Colors live in an asset catalog with light and dark variants.
- `Components` contains reusable views such as buttons, cards, input fields, and empty states.
- `Resources` contains the asset catalog and fonts.

Components accept plain values and closures, never domain entities.
Depends on: `SwiftUI` only.

### NoteCache

The latest note of the partner, shared between the application and the widget through the App Group container. The note is stored as a versioned JSON file and is replaced only by a note with a newer `updated_at`. The package also keeps the WidgetKit push token that the widget passes to the application and the widget secret that the application creates for the widget.
Depends on: `Foundation` only.

### Features

One package per feature. A feature package contains only presentation code: views, view models, routes, and outputs.
Depends on: `Domain`, `DesignSystem`.

### Application Target

The composition root, the application entry point, and the router.
Depends on: all packages.

### Widget Extension

The widget timeline provider, the widget push handler, the widget views, and a small container that wires the repository and the use cases. The widget fetches the latest note with `FetchPartnerNoteUseCase`, stores it in `NoteCache`, and registers its WidgetKit push token with `RegisterWidgetPushTokenUseCase`.
Depends on: `Domain`, `WidgetData`, `NoteCache`, `DesignSystem`.

## Dependency Graph

```
Application ──▶ Features, Data, DesignSystem, NoteCache
Widget      ──▶ Domain, WidgetData, NoteCache, DesignSystem
Features    ──▶ Domain, DesignSystem
Data        ──▶ Domain, Supabase
WidgetData  ──▶ Domain
```

## Package Boundaries

- Only the application target imports `Data`, and only the widget extension imports `WidgetData`.
- Feature packages never import other feature packages.
- The widget extension never imports `Data` or any feature.
- `DesignSystem` and `NoteCache` never import `Domain`.

## Fakes

Fake implementations are not shared through a package.

- A test target declares the fakes it needs next to its tests as `private` types.
- A preview that needs a use case uses a `private` type declared in the same file as the screen.

## Access Control

- Types and members that form a package's interface are `public`.
- Everything else keeps the default `internal` access level.

## Actor Isolation

- `DesignSystem` and all feature packages use `MainActor` as their default isolation.
- `Domain`, `Data`, and `NoteCache` use the default `nonisolated` setting.

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
        .library(name: "WidgetData", targets: ["WidgetData"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Data",
            dependencies: [
                "Domain",
                .product(name: "Supabase", package: "supabase-swift"),
            ]
        ),
        .target(name: "WidgetData", dependencies: ["Domain"]),
        .testTarget(name: "DataTests", dependencies: ["Data"]),
        .testTarget(name: "WidgetDataTests", dependencies: ["WidgetData", "Domain"]),
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
        .package(path: "../../DesignSystem"),
    ],
    targets: [
        .target(
            name: "MessageFeature",
            dependencies: ["Domain", "DesignSystem"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(
            name: "MessageFeatureTests",
            dependencies: ["MessageFeature"]
        ),
    ]
)
```

## Adding a Feature

1. Create the package in `Packages/Features/<Name>` with the `<Name>Feature` library.
2. Declare dependencies on `Domain` and `DesignSystem`, and set `MainActor` as the default isolation.
3. Add the `<Name>FeatureTests` test target.
4. Add the package to the Xcode project and link the library to the application target.
5. Add a factory method for the feature to `AppContainer`.
6. Register the feature's routes and outputs in the router.

## Naming

- Package folders are named after their purpose: `Domain`, `Data`, `Features/<Name>`.
- Feature packages, products, and targets are named `<Name>Feature`.
- Test targets are named after the target they test with the `Tests` suffix.
- Each file contains one primary type and is named after it.
