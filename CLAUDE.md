# CoupleWidget

Love Tunnel is an iOS app for couples. Partners send each other short notes that appear on the Home Screen widget. The app is written in SwiftUI with Swift 6.2, targets iOS 26 on iPhone, and uses Supabase as the backend.

## Project Layout

- `CoupleWidget/` is the application target and the composition root. It holds `AppContainer`, `AppRouter`, and the root screen selection in `CoupleWidgetApp`.
- `Packages/Domain` holds entities, use cases, and repository protocols.
- `Packages/Data` implements the Domain protocols and is the only place that talks to Supabase.
- `Packages/DesignSystem` holds colors, typography, spacing, and shared components.
- `Packages/Features/` contains one package per feature with presentation code only.
- `Tools/ViewStyleLint` is the SwiftSyntax checker for SwiftUI views.

Layers, packages, MVVM, and navigation are described in [docs/architecture](docs/architecture/README.md). Read the relevant document before changing a layer, a package boundary, a view model, or navigation.

## Build and Test

Build the application:

```bash
xcodebuild -project CoupleWidget.xcodeproj -scheme CoupleWidget -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

The packages are iOS only, so `swift test` does not work for them. Run their tests from the package directory with the package scheme:

```bash
cd Packages/Features/Main && xcodebuild test -scheme MainFeature -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

The checker is a macOS package and is tested with SwiftPM:

```bash
swift test --package-path Tools/ViewStyleLint
```

## Code Style

- Everything in the repository is written in English: code, string literals, documentation, and commit messages.
- Code has no comments. This also applies to code blocks in documentation.
- SwiftUI views follow the `swiftui-view-style` skill.
- SwiftLint and the view style checker run in the Xcode build, in the pre-commit hook, and after every edit made by Claude Code. Violations are fixed in code, not by disabling rules.
- The pre-commit hook is enabled once per clone with `git config core.hooksPath .githooks`.

## Working Agreements

- Designs and documented decisions are implemented exactly. When a value, a behavior, or an architectural choice is missing or ambiguous, ask instead of deciding.
- Commits are made only when requested.
