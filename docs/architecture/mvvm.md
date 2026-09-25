# MVVM

The Presentation layer follows the Model–View–ViewModel pattern. Views render state, view models own that state and talk to the Domain layer, and models are the domain entities described in [Clean Architecture](clean-architecture.md).

```
View ──▶ ViewModel ──▶ Use Case Protocols
  ▲          │
  └──────────┘
     state
```

## Model

The model is the set of Domain entities. The Presentation layer never defines its own copies of business types and never sees data transfer objects.

## ViewModel

### Responsibilities

A view model owns the state of one screen and performs the actions available on it.

- It calls use cases and updates its state with the results.
- It converts Domain errors into localized, user-facing messages.
- It knows nothing about views, other features, or the Data layer.

### Declaration

- A view model is an `@Observable final class`.
- It is isolated to the main actor through the default isolation of its feature package.
- It receives use case protocols through its initializer and never depends on concrete implementations.

### State

- Mutually exclusive states of a screen are modeled as a single `enum State`, for example `loading`, `empty`, `loaded`, and `failed`.
- Independent values, such as the text of an input field, are separate properties.
- State that the view must not change directly is `private(set)` and modified only through view model methods.

### Asynchronous Work

- Actions that perform asynchronous work are `async` methods.
- The view starts them from `.task` or from an action handler, so the work is cancelled together with the view.

### Errors

- Business area errors, such as `MessageError.tooLong`, are converted into messages and shown on the screen.
- `CommonError.network` is not shown by the screen. The application displays the connection screen, as described in [Navigation](navigation.md).

### Example

```swift
import Domain
import Observation

@Observable
final class ComposeMessageViewModel {
    enum State: Equatable {
        case idle
        case sending
        case sent
        case failed(String)
    }

    var text = ""
    private(set) var state: State = .idle

    private let couple: CoupleID
    private let sendMessage: SendMessageUseCase

    init(couple: CoupleID, sendMessage: SendMessageUseCase) {
        self.couple = couple
        self.sendMessage = sendMessage
    }

    func send() async {
        state = .sending
        do {
            _ = try await sendMessage(text, to: couple)
            text = ""
            state = .sent
        } catch MessageError.empty {
            state = .failed(String(localized: "Write something first"))
        } catch MessageError.tooLong {
            state = .failed(String(localized: "The message is too long"))
        } catch {
            state = .idle
        }
    }
}
```

## View

### Responsibilities

A view renders the current state of its view model and forwards user actions to it.

- A view contains no business logic and never calls use cases directly.
- A view may own purely visual state, such as focus or animation phase.

### Ownership

- A screen owns its view model through `@State`.
- There is one view model per screen. Child views receive plain values, bindings, or closures, not the parent's view model.

### Composition

- `body` stays short and declarative.
- Reusable or large parts are extracted into separate `View` types.
- Colors, typography, spacing, and shared components come from `DesignSystem`.

### Reloading After Reconnection

The application publishes the connection status to views through the `isOnline` environment value. A screen that loads data starts its loading task with `.task(id: isOnline)`, so the data is reloaded automatically when the connection returns.

### Previews

Every screen has previews in light and dark appearance. Previews use fake use cases from the `DomainFakes` package, so they never access the network. Fakes are referenced only inside `#Preview` blocks.

### Example

```swift
import DesignSystem
import DomainFakes
import SwiftUI

struct ComposeMessageView: View {
    @State private var model: ComposeMessageViewModel

    init(model: ComposeMessageViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        VStack(spacing: Spacing.medium) {
            MessageField(text: $model.text)
            PrimaryButton(title: String(localized: "Send"), isLoading: model.state == .sending) {
                Task { await model.send() }
            }
        }
    }
}

#Preview {
    ComposeMessageView(model: ComposeMessageViewModel(
        couple: .preview,
        sendMessage: FakeSendMessageUseCase()
    ))
}
```

## Feature Structure

Each feature is a separate package that contains only presentation code.

```
Features/Message/
    Package.swift
    Sources/MessageFeature/
        MessageFeature.swift
        MessageRoute.swift
        MessageOutput.swift
        Compose/
            ComposeMessageView.swift
            ComposeMessageViewModel.swift
        Components/
    Tests/MessageFeatureTests/
```

- `MessageFeature.swift` is the public entry point. It receives use case protocols and builds the feature's screens.
- `MessageRoute.swift` and `MessageOutput.swift` describe the feature's navigation, as explained in [Navigation](navigation.md).
- Each screen has its own folder with a view and its view model.
- `Components/` contains views used only within this feature.
