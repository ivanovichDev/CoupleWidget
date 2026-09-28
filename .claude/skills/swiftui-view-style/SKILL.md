---
name: swiftui-view-style
description: "Code style for SwiftUI views in CoupleWidget. Use whenever creating, editing, splitting, or reviewing a SwiftUI View in the app target, DesignSystem, or any feature package: one view per file, body as the only member that returns a view, and where extracted child views are placed."
---

# SwiftUI View Style

These rules apply to every type that conforms to `View`. View modifiers, `View` extensions, and feature entry points such as `SignInFeature` are not covered.

## One View per Type

`body` is the only member of a view that returns a view.

- A view has no computed properties that return `some View`.
- A view has no methods that return `some View`, with or without `@ViewBuilder`.
- Every other part of the layout is a separate `View` type that the parent uses inside `body`.

Incorrect:

```swift
struct OrDivider: View {
    var body: some View {
        HStack {
            line
            Text(String(localized: "or"))
            line
        }
    }

    private var line: some View {
        Rectangle()
            .frame(height: 1)
    }
}
```

Correct:

```swift
struct OrDivider: View {
    var body: some View {
        HStack {
            OrDividerLine()
            Text(String(localized: "or"))
            OrDividerLine()
        }
    }
}
```

```swift
struct OrDividerLine: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
    }
}
```

Computed properties that return values such as `AttributedString`, `CGFloat`, or `Bool` are allowed.

## No Methods

A view declares no methods. Logic that a view would otherwise keep in a method belongs to its view model.

- A screen moves such logic into its own view model.
- A component with logic of its own, such as rendering or starting an animation, gets its own `@Observable` view model, owned through `@State`.
- Simple action closures passed to child views, such as `{ withAnimation { model.send() } }`, stay inline in `body`.
- Focus state lives in the view as `@FocusState` and is mirrored into a plain property of the view model with two `onChange` modifiers when the view model needs to change it.

## Member Order

Members of a view are declared in this order:

1. Environment values, state, bindings, and stored properties.
2. Initializers.
3. Computed properties.
4. `body`, always the last member.

## One View per File

- A file contains exactly one `View` type.
- The file is named after that type.
- `#Preview` blocks and the `private` preview fakes described in the MVVM document stay in the same file as the view they preview.

## Placement of Extracted Views

- A child view of a screen goes into a `Components/` folder inside that screen's folder, for example `SignIn/Components/TermsText.swift` next to `SignIn/SignInView.swift`.
- A child view of a view that already lives in a `Components/` folder goes into that same `Components/` folder.
- A child view of a view in the application target follows the same rule relative to its parent's folder, for example `Navigation/Components/`.

## Declaration of Extracted Views

- An extracted view has `internal` access. It is `public` only when it is part of the public interface of `DesignSystem`.
- An extracted view receives plain values, bindings, `FocusState` bindings, and closures. It never receives the parent's view model.
- An extracted view is named after what it shows, prefixed with its parent's name when the name alone would be ambiguous, for example `PageDots`, `SendButton`, `ProgressiveBlurLayer`.
