# Navigation

Features do not know about each other, so navigation between them is owned by the application target. Each feature describes its own screens and the events it can emit. A single router in the application target turns those descriptions into navigation.

```
Feature ──push(Route)──▶ Router ──▶ NavigationPath
Feature ──output(Output)──▶ Router ──▶ another feature's Route
```

## Router

`AppRouter` is an `@Observable` class in the application target. It owns the complete navigation state of the application:

- the current root screen;
- the `NavigationPath` of the main navigation stack;
- the currently presented sheet or full-screen cover;
- the connection status.

Only the router changes navigation state. Features request changes through their navigators.

## Root Screen

The screen at the base of the navigation stack is selected by `RootScreen`:

```swift
enum RootScreen: Equatable {
    case splash
    case signIn
    case onboarding(OnboardingRoute)
    case home(CoupleID)
}
```

The application starts with `splash`, which matches the launch screen. While it is shown, the router asks `SessionStateUseCase` for the current state and selects the root screen:

- without a session, the sign-in screen;
- with a session and an incomplete profile, the name step of onboarding;
- with a complete profile and no couple, the invite step of onboarding with the user's pairing code;
- with a couple, the home screen.

After a successful sign-in the router performs the same check. Changing the root screen replaces the base of the stack and resets the navigation path, so no previous screens remain. Screens inside the current root screen are opened through feature routes.

## Feature Routes

A feature describes the screens it can show with its own route type.

- A route is a `public enum` that conforms to `Hashable`.
- A case carries all the values its screen needs.
- The feature's entry point builds the view for any of its routes.

```swift
public enum MessageRoute: Hashable {
    case compose
    case history
}

public struct MessageFeature {
    public init(couple: CoupleID, sendMessage: SendMessageUseCase, latestMessage: LatestMessageUseCase)

    public func view(for route: MessageRoute, navigator: MessageNavigator) -> some View
}
```

## Feature Outputs

A feature describes the events that leave the feature with its own output type. An output states what happened, not where to go next.

```swift
public enum MessageOutput {
    case messageSent
    case settingsRequested
}
```

## Navigator

Each feature receives a navigator from the router. The navigator is the only way a feature can affect navigation.

```swift
public struct MessageNavigator {
    public let push: (MessageRoute) -> Void
    public let dismiss: () -> Void
    public let output: (MessageOutput) -> Void
}
```

- `push` opens another screen of the same feature.
- `dismiss` closes the current screen.
- `output` reports an event that the router handles.

## Handling Outputs

The router translates outputs into navigation. This is the only place where one feature leads to another.

```swift
func handle(_ output: MessageOutput) {
    switch output {
    case .messageSent:
        path.removeLast(path.count)
    case .settingsRequested:
        path.append(SettingsRoute.root)
    }
}
```

## Destination Registration

All destinations are registered in one place, on the root navigation stack:

```swift
NavigationStack(path: $router.path) {
    rootView
        .navigationDestination(for: MessageRoute.self) { route in
            container.messageFeature.view(for: route, navigator: router.messageNavigator)
        }
        .navigationDestination(for: SettingsRoute.self) { route in
            container.settingsFeature.view(for: route, navigator: router.settingsNavigator)
        }
}
```

Every new feature adds exactly one registration here. The router exposes typed methods such as `push(_ route: MessageRoute)` so that only registered route types can enter the path.

## Modal Presentation

Sheets and full-screen covers are described by the router's `Modal` enum. Each case wraps a feature route. The root view presents the current modal with `.sheet(item:)` or `.fullScreenCover(item:)`, and the feature closes it through `dismiss`.

## Connection Screen

When `ConnectivityMonitoring` reports that the device is offline, the router shows the connection screen above all content. The screen blocks interaction with the application until the connection returns.

When the connection returns:

1. The router removes the connection screen.
2. The navigation state is preserved, so the user stays on the same screen.
3. The router updates the `isOnline` environment value, and screens that load data reload it as described in [MVVM](mvvm.md).

Features never check connectivity themselves and never display network errors.
