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
    associatedtype State
    associatedtype Action
    @MainActor func reduce(into state: inout State, action: Action) async
}
```

- Defines state, actions, and state transition logic.
- `@MainActor` + `async` ensures safe async UI updates.

---

### `Store` Class

```swift
final class Store<Feature: FeatureType>: ObservableObject {
    @Published var state: Feature.State
    private var feature: Feature

    init(feature: Feature, initialState state: Feature.State) {
        self.feature = feature
        self.state = state
    }

    @MainActor
    func send(action: Feature.Action) {
        Task {
            await feature.reduce(into: &state, action: action)
        }
    }

    func binding<T: Equatable>(for keyPath: WritableKeyPath<Feature.State, T>, action: Feature.Action.BindingAction) -> Binding<T> where Feature.Action: BindableAction {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { newValue in
                guard self.state[keyPath: keyPath] != newValue else { return }
                self.state[keyPath: keyPath] = newValue
                Task {
                    await self.send(action: .binding(action))
                }
            }
        )
    }
}
```

- Manages action dispatch and state updates.
- Automatically syncs with SwiftUI through `@Published`.

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
class Dependencies: ObservableObject {
    var service: ServiceType
    init(service: ServiceType) {
        self.service = service
    }
}

@EnvironmentObject var dependency: Dependencies
```

- Use `@EnvironmentObject` to inject dependencies into Features or Views.
- Makes testing and mocking simpler.

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
class MockCounterFeatureDependency: CounterFeatureDependencyType {
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

---

## 🛠 Future Improvements

-

---

## 📄 License

MIT License

