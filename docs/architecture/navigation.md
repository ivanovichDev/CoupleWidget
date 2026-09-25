# Navigation

Features do not know about each other, so navigation between them is owned by the application target. Each feature describes its own screens and the events it can emit. A single router in the application target turns those descriptions into navigation.

```
Feature ──push(Route)──▶ Router ──▶ NavigationPath
Feature ──output(Output)──▶ Router ──▶ another feature's Route
```

## Router

`AppRouter` is an `@Observable` class in the application target. It owns the complete navigation state of the application:

- the current application flow;
- the `NavigationPath` of the main navigation stack;
- the currently presented sheet or full-screen cover;
- the connection status.

Only the router changes navigation state. Features request changes through their navigators.

## Application Flow

The root of the application is selected by `AppFlow`:

```swift
enum AppFlow: Equatable {
    case launching
    case signedOut
    case unpaired
    case paired(CoupleID)
}
```

The router derives the flow from the session and couple state provided by Domain. Each flow has its own root view. Changing the flow replaces the root view and resets the navigation path.

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
