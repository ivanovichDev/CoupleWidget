# Architecture

CoupleWidget is built on three complementary ideas. Clean Architecture defines the layers of the application and the direction in which they may depend on each other. MVVM defines how the presentation layer is built with SwiftUI. Swift Package Manager turns layers and features into separate packages, so the boundaries between them are enforced by the compiler rather than by convention.

## How They Work Together

Clean Architecture divides the application into Domain, Data, and Presentation. Domain holds the business rules and knows nothing about frameworks or the backend. Data implements the protocols declared in Domain and is the only place that communicates with Supabase. Presentation shows data to the user and depends only on Domain.

MVVM is the structure of the Presentation layer. A view renders state and forwards user actions. A view model owns that state, calls Domain use cases through their protocols, and translates results and errors into something the view can display. The model is the set of Domain entities.

Swift Package Manager gives Domain and Data one package each. The Presentation layer is split by feature: every feature is its own package that contains only user interface code. A feature package can import Domain but never Data and never another feature. The application target sits on top of all packages as the composition root. It creates the Data implementations, builds the use cases, injects them into features, and connects the features through a single router.

A typical request flows through all three:

```
View ──▶ ViewModel ──▶ Use Case ──▶ Repository
                                        ▲
                                        │ implements
                                        │
                               Supabase Repository
```

The view asks its view model to perform an action. The view model calls a use case protocol from Domain. The use case applies business rules and calls a repository protocol. The Data layer implementation of that protocol talks to Supabase and returns domain entities. The result travels back to the view model, which updates its state, and the view re-renders.

## Documents

- [Clean Architecture](clean-architecture.md)
- [MVVM](mvvm.md)
- [Swift Package Manager](spm.md)
- [Navigation](navigation.md)
