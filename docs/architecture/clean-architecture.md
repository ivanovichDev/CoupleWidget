# Clean Architecture

CoupleWidget is organized into layers with a strict direction of dependencies. Business rules sit at the center and do not depend on the user interface, the backend, or any framework. Everything else depends on them.

## Layers

### Domain

The Domain layer describes what the application does. It contains entities, repository protocols, use cases, and errors. It has no knowledge of how data is stored or displayed.

### Data

The Data layer describes where data comes from. It implements the protocols declared in Domain using Supabase and system services, and converts external data into domain entities.

### Presentation

The Presentation layer describes how data is shown and how the user interacts with it. It consists of feature packages built with SwiftUI and is described in [MVVM](mvvm.md).

### Composition Root

The composition root is the application target. It creates the concrete implementations from the Data layer, builds the use cases, injects them into features, and starts the application. It is the only place that knows about every layer.

## Dependency Rule

Dependencies always point toward Domain:

```
Presentation ──▶ Domain ◀── Data
```

- Domain depends on nothing except `Foundation`.
- Data depends on Domain and implements its protocols.
- Presentation depends on Domain and works only with its protocols.
- Presentation and Data never depend on each other.

Every layer is a separate package, so the compiler rejects any import that violates this rule. The package setup is described in [Swift Package Manager](spm.md).

## Domain Layer

### Organization

Domain is a single package organized by business area. Each area keeps its entities, repository protocols, use cases, and errors together.

```
Domain/Sources/Domain/
    Common/
    Session/
    Couple/
    Message/
    Connectivity/
```

`Common` contains only the types shared by every area, such as identifiers and common errors.

### Entities

Entities are the core business types of the application.

- Entities are value types: `struct`, `Sendable`, `Equatable`, and `Identifiable` when they have an identity.
- Entities do not conform to `Codable`. Serialization belongs to the Data layer.
- Identifiers are strongly typed wrappers such as `UserID` and `CoupleID`, not raw `UUID` or `String` values.

```swift
public struct CoupleID: Hashable, Sendable {
    public let rawValue: UUID

    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }
}

public struct Message: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let authorID: UserID
    public let text: String
    public let sentAt: Date
}
```

### Repository Protocols

A repository protocol defines how the application reads and writes one kind of data without specifying where that data lives.

- Repository protocols are declared in Domain and implemented in Data.
- Methods are `async throws` and accept and return only domain types.
- Protocols conform to `Sendable`.

```swift
public protocol MessageRepository: Sendable {
    func latestMessage(in couple: CoupleID) async throws -> Message?
    func send(_ text: String, to couple: CoupleID) async throws -> Message
}
```

### Use Cases

A use case represents a single business operation. It holds the business rules for that operation and coordinates one or more repositories.

- Every operation available to the user is a use case, including simple reads.
- Every use case is declared as a protocol and implemented by a type with the `App` prefix.
- View models depend on use case protocols and never call repositories.
- A use case exposes a single `callAsFunction` method.
- A use case implementation receives its repositories through its initializer.

```swift
public protocol SendMessageUseCase: Sendable {
    func callAsFunction(_ text: String, to couple: CoupleID) async throws -> Message
}

public struct AppSendMessageUseCase: SendMessageUseCase {
    private let repository: MessageRepository

    public init(repository: MessageRepository) {
        self.repository = repository
    }

    public func callAsFunction(_ text: String, to couple: CoupleID) async throws -> Message {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw MessageError.empty }
        guard trimmed.count <= 200 else { throw MessageError.tooLong }
        return try await repository.send(trimmed, to: couple)
    }
}
```

### Errors

Errors are split into common errors and business area errors. Errors from frameworks and SDKs never cross into Domain.

Common errors describe failures that any operation can produce:

```swift
public enum CommonError: Error, Equatable, Sendable {
    case network
    case unauthorized
    case unknown
}
```

Each business area defines errors for its own rules:

```swift
public enum MessageError: Error, Equatable, Sendable {
    case empty
    case tooLong
}
```

## Data Layer

### Organization

Data is a single package that mirrors the business areas of Domain.

```
Data/Sources/Data/
    Supabase/
    Session/
    Couple/
    Message/
    Connectivity/
```

`Supabase` contains the client configuration and the mapping of SDK errors to `CommonError`.

### Data Transfer Objects

Data transfer objects mirror the shape of backend tables and responses.

- DTOs are `Codable` and use `snake_case` coding keys that match the database.
- DTOs are internal to the Data package and never returned to other layers.
- Each DTO has a mapping to its domain entity.

```swift
struct MessageDTO: Codable {
    let id: UUID
    let authorId: UUID
    let coupleId: UUID
    let text: String
    let sentAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case authorId = "author_id"
        case coupleId = "couple_id"
        case sentAt = "sent_at"
    }
}

extension MessageDTO {
    var domain: Message {
        Message(id: id, authorID: UserID(rawValue: authorId), text: text, sentAt: sentAt)
    }
}
```

### Repositories

A repository implements a Domain protocol using a concrete data source. Implementations are named after their source, such as `SupabaseMessageRepository`.

- The Data package is the only package that imports `Supabase`.
- A repository receives its client through the initializer. The application uses a single client instance.
- A repository only fetches, persists, and maps data. It contains no business rules.
- Every SDK error is converted into a Domain error before it leaves the repository.

```swift
import Domain
import Supabase

public final class SupabaseMessageRepository: MessageRepository {
    private let client: SupabaseClient

    public init(client: SupabaseClient) {
        self.client = client
    }

    public func latestMessage(in couple: CoupleID) async throws -> Message? {
        do {
            let rows: [MessageDTO] = try await client
                .from("messages")
                .select()
                .eq("couple_id", value: couple.rawValue)
                .order("sent_at", ascending: false)
                .limit(1)
                .execute()
                .value
            return rows.first?.domain
        } catch {
            throw CommonError(error)
        }
    }
}
```

### Streams

Continuous updates, such as a new message from the partner or a change in connectivity, are exposed through Domain protocols as `AsyncStream` of domain values. Backend channels, subscriptions, and system monitors stay inside the Data layer.

### Connectivity

Domain declares a `ConnectivityMonitoring` protocol that publishes the connection status as a stream. The Data implementation combines two signals: the system network monitor and network failures reported by repositories. The status becomes offline when either signal reports a problem and online again when the network monitor confirms a working connection. How the application reacts to this status is described in [Navigation](navigation.md).

## Error Flow

Errors are translated at each boundary:

1. The Data layer catches SDK and network errors and converts them into `CommonError`.
2. Use cases throw business area errors for violated rules.
3. The view model converts Domain errors into localized messages for the user.
4. `CommonError.network` is not shown by the view model. It is handled once for the whole application by the connectivity flow.

## Composition Root

All concrete types are created in `AppContainer` in the application target.

- Every repository and use case implementation is created once and shared by all features that need it.
- Dependencies are passed through initializers. Singletons and service locators are not used.
- Features never construct their own dependencies. They receive use case protocols through their entry points.
- SwiftUI `Environment` carries only user interface concerns, never repositories or use cases.

```swift
import Data
import Domain
import MessageFeature
import Supabase

@MainActor
final class AppContainer {
    private let supabase: SupabaseClient
    private let messageRepository: MessageRepository

    init(configuration: AppConfiguration) {
        supabase = SupabaseClient(
            supabaseURL: configuration.supabaseURL,
            supabaseKey: configuration.supabaseKey
        )
        messageRepository = SupabaseMessageRepository(client: supabase)
    }

    func makeMessageFeature(couple: CoupleID) -> MessageFeature {
        MessageFeature(
            couple: couple,
            sendMessage: AppSendMessageUseCase(repository: messageRepository),
            latestMessage: AppLatestMessageUseCase(repository: messageRepository)
        )
    }
}
```
