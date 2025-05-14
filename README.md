# SwiftUI State Management Architecture (TCA-style)

> Originally inspired by MVI, this custom framework evolved into a TCA-style architecture optimized for SwiftUI.\
> It balances testability, async handling, and declarative UI-friendly bindings.

---

## 🧩 Overview

This framework includes the following key components:

- **Storable Protocol**: Simplifies integration of `Store` into SwiftUI Views.
- **FeatureType Protocol**: Defines `State`, `Action`, and the async reducer function.
- **Store Class**: Maintains state and handles actions; supports two-way bindings.
- **DependencyType Abstraction**: Decouples business logic from external services to improve testability.
- **Scoping System**: Enables hierarchical state management and action propagation.

---

## 🧱 Core Components

### `Storable` Protocol

```swift
protocol Storable: View {
    associatedtype Feature: FeatureType
    var store: Store<Feature> { get }
}
```

- Provides a standard interface for connecting Views with Stores.

---

### `FeatureType` Protocol

```swift
protocol FeatureType {
    associatedtype State: Sendable
    associatedtype Action: Sendable
    @MainActor func reduce(state: State, action: Action) async -> Self.State
}
```

- Defines state, actions, and state transition logic.
- `@MainActor` + `async` ensures safe async UI updates.

---

### `Store` Class

```swift
@MainActor
final class Store<Feature: FeatureType>: ObservableObject {
    @Published var state: Feature.State
    private var feature: Feature

    init(feature: Feature, initialState state: Feature.State) {
        self.feature = feature
        self.state = state
    }

    func send(action: Feature.Action) {
        Task { @MainActor in
            await send(action: action)
        }
    }

    func send(action: Feature.Action) async {
        state = await feature.reduce(state: state, action: action)
    }

    func binding<T: Equatable>(for keyPath: WritableKeyPath<Feature.State, T>, action: Feature.Action.BindingAction) -> Binding<T> where Feature.Action: BindableAction {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { newValue in
                guard self.state[keyPath: keyPath] != newValue else { return }
                self.state[keyPath: keyPath] = newValue
                self.send(action: .binding(action))
            }
        )
    }

    func scope<ScopedFeature: FeatureType>(
        state: WritableKeyPath<Feature.State, ScopedFeature.State>,
        action: @escaping (ScopedFeature.Action) -> Feature.Action,
        feature: ScopedFeature
    ) -> Store<ScopedFeature> {
        ScopedStore(
            parent: self,
            state: state,
            action: action,
            feature: feature
        )
    }
}
```

- Manages action dispatch and state updates.
- Automatically syncs with SwiftUI through `@Published`.
- Supports scoping for hierarchical state management.

---

### `BindableAction` Protocol

```swift
protocol BindableAction {
    associatedtype BindingAction
    static func binding(_ action: BindingAction) -> Self
}
```

- Maps user input into state-changing actions for binding convenience.

---

## 🔌 Dependency Injection

```swift
protocol CounterFeatureDependency: Sendable {
    func increment(int: Int) async -> Int
    func decrement(int: Int) async -> Int
}

final class Dependencies: Sendable, ObservableObject {
    let service: ServiceType

    init(service: ServiceType) {
        self.service = service
    }
}

protocol ServiceType: Sendable {
    func increment(int: Int) async -> Int
    func decrement(int: Int) async -> Int
}

struct Service: ServiceType {
    func increment(int: Int) async -> Int {
        await Task.detached {
            var result = int
            result += 1
            return result
        }.value
    }
    
    func decrement(int: Int) async -> Int {
        await Task.detached {
            var result = int
            result -= 1
            return result
        }.value
    }
}
```

- Makes testing and mocking simpler.

---

## 🎯 Scoping

### Overview
Scoping allows you to create hierarchical state management by nesting features within each other. This enables:
- State isolation between features
- Action propagation from child to parent
- Independent testing of features
- Reusable feature components

### Implementation
```swift
// Parent Feature
struct ParentFeature: FeatureType {
    struct State {
        var childState: ChildFeature.State
    }
    
    enum Action {
        case child(ChildFeature.Action)
    }
}

// Child Feature
struct ChildFeature: FeatureType {
    struct State {
        var count: Int
    }
    
    enum Action {
        case increment
        case decrement
    }
}

// Scoped View Implementation
struct ParentView: Storable {
    @MainActor let store: Store<ParentFeature>
    
    var body: some View {
        VStack {
            ChildView(store: store.scope(
                state: \.childState,
                action: ParentFeature.Action.child,
                feature: ChildFeature(dependency: dependency)
            ))
        }
    }
}
```

### Benefits
1. **State Isolation**: Each feature manages its own state
2. **Action Propagation**: Child actions bubble up to parent
3. **Reusability**: Features can be reused independently
4. **Testability**: Features can be tested in isolation

---

## 📍 State Transition Flow

```
[View] 
   ↓ send(action)
[Store] 
   ↓ 
[Feature.reduce] 
   ↓ 
[State Update] 
   ↓ 
[SwiftUI Auto Update]
```

---

## 🧪 Example: Testing

### Mock Example

```swift
final class MockCounterFeatureDependency: CounterFeatureDependency {
    func increment(int: Int) async -> Int { int + 1 }
    func decrement(int: Int) async -> Int { int - 1 }
}
```

### Unit Test Example

```swift
@Test func testIncrementAction() async throws {
    let store = Store<CounterView.Feature>(
        feature: .init(dependency: MockCounterFeatureDependency()),
        initialState: .init()
    )
    await store.send(action: .increment)
    #expect(store.state.count == 1)
}
```

---

## ✅ Summary

| Feature            | Description                                      |
| ------------------ | ------------------------------------------------ |
| SwiftUI-friendly   | Works with `@Published`, `Binding`, `@MainActor` |
| Unidirectional     | MVI-based state → view → intent → state loop     |
| Testable           | Features can be unit tested independently        |
| Decoupled DI       | Business logic is externalized via dependencies  |
| Integrated Binding | Seamlessly maps SwiftUI inputs to state changes  |
| Hierarchical       | Supports nested features through scoping         |

---

## 📄 License

MIT License

