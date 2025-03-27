# SwiftUI Redux Framework

This project is an example implementation of a Redux-style state management system in SwiftUI. It is designed with extensibility, testability, and ease of use in mind. The framework separates state management and UI components using protocols and generics.

---

## 📋 Overview

The framework consists of the following components:

1. **`Storable` Protocol**  
   Provides a standard interface to integrate `Store` into SwiftUI views.

2. **`FeatureType` Protocol**  
   Defines state and actions, and implements state management logic through a `reduce` method.

3. **`Store` Class**  
   Manages state, processes actions, and integrates with `FeatureType`.

---

## 🛠️ Core Components

### **`Storable` Protocol**
```swift
protocol Storable: View {
    associatedtype Feature: FeatureType
    var store: Store<Feature> { get }
}
```

- A protocol for integrating `Store` into SwiftUI `View`s.
- `Feature` must conform to `FeatureType`.

---

### **`FeatureType` Protocol**

`FeatureType` plays a key role in Redux-style state management. It defines the state and actions and provides the `reduce` method to update the state according to the action.

```swift
protocol FeatureType {
    associatedtype State
    associatedtype Action
    @MainActor func reduce(into state: inout State, action: Action) async
}
```

#### **Components**
1. **`State`**  
   - Represents the current state of the application.  
   - Typically defined as a struct and kept immutable.

2. **`Action`**  
   - Represents user interactions, events, or other state change requests.  
   - Usually defined as an enum to clearly list all possible actions.

3. **`reduce` Method**  
   - Core logic for updating the state.  
   - Modifies `State` based on the specific `Action`, supporting async operations.  
   - Uses `@MainActor` to safely update UI on the main thread.

---

### **`Store` Class**
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
}
```

- **State Management**:  
  Uses `@Published` for seamless integration with SwiftUI on state changes.

- **Action Handling**:  
  Delivers actions to the `reduce` method to update the state.

---

## 🎯 Key Features

- **Scalable State Management**:  
  Easily add new state logic by conforming to `FeatureType`.

- **Seamless Integration with SwiftUI**:  
  Uses `@Published` and `@StateObject` for immediate UI updates on state changes.

- **Async Support**:  
  Supports modern async operations using `async/await`.

---

# Dependency Injection in the SwiftUI Redux Framework

`CounterFeatureDependencyType` is an essential interface for implementing dependency injection in Redux-style state management.

---

## 🔗 Dependency Injection Structure

### **`CounterFeatureDependencyType` Protocol**

This protocol is used to separate business logic from external dependencies, improving flexibility and testability.

```swift
protocol CounterFeatureDependencyType {
    func increment(int: Int) async -> Int
    func decrement(int: Int) async -> Int
}
```

### **`Dependencies` Extension**

The `Dependencies` object implements `CounterFeatureDependencyType` to connect with the actual service.

```swift
extension Dependencies: CounterFeatureDependencyType {
    func increment(int: Int) async -> Int {
        await service.increment(int: int)
    }

    func decrement(int: Int) async -> Int {
        await service.decrement(int: int)
    }
}
```

`Dependencies` encapsulates the dependency on `Service`, making it available to `CounterView.Feature`.

---

## 🔗 Integration Example

`CounterFeatureDependencyType` is injected as a dependency into `CounterView.Feature`.

### **Usage in `CounterView.Feature`**

```swift
struct CounterView: Storable {
    @EnvironmentObject var dependency: Dependencies
    @StateObject var store: Store<CounterView.Feature>

    var body: some View {
        Text("count: \(store.state.count)")

        Button("Increment") {
            store.send(action: .increment)
        }

        Button("Decrement") {
            store.send(action: .decrement)
        }
    }
}

extension CounterView {
    struct Feature: FeatureType {

        struct State {
            var count: Int
        }

        enum Action {
            case increment
            case decrement
        }

        var dependency: CounterFeatureDependencyType

        init(dependency: CounterFeatureDependencyType) {
            self.dependency = dependency
        }

        func reduce(into state: inout State, action: Action) async {
            switch action {
            case .increment:
                state.count = await dependency.increment(int: state.count)
            case .decrement:
                state.count = await dependency.decrement(int: state.count)
            }
        }
    }
}
```

### **Dependency Injection in Preview**

In previews, initialize the `Dependencies` object and inject it into `CounterView`.

```swift
#Preview {
    let dependency = Dependencies(service: Service())
    CounterView(store: .init(
        feature: .init(dependency: dependency),
        initialState: .init(count: 0)
    )).environmentObject(dependency)
}
```

---

## 🎯 Testability

### **Mock Implementation Example**

Provide a mock implementation of `CounterFeatureDependencyType` for testing.

```swift
class MockCounterFeatureDependency: CounterFeatureDependencyType {
    func increment(int: Int) async -> Int {
        return int + 1 // Always increment by 1
    }

    func decrement(int: Int) async -> Int {
        return int - 1 // Always decrement by 1
    }
}
```

### **Example Test Code**

Here's an example of writing unit tests:

```swift
import XCTest

@MainActor
final class CounterFeatureTests: XCTestCase {
    func testIncrementAction() async throws {
        // Given
        let mockDependency = MockCounterFeatureDependency()
        var state = CounterView.Feature.State(count: 0)
        let feature = CounterView.Feature(dependency: mockDependency)

        // When
        await feature.reduce(into: &state, action: .increment)

        // Then
        XCTAssertEqual(state.count, 1)
    }

    func testDecrementAction() async throws {
        // Given
        let mockDependency = MockCounterFeatureDependency()
        var state = CounterView.Feature.State(count: 1)
        let feature = CounterView.Feature(dependency: mockDependency)

        // When
        await feature.reduce(into: &state, action: .decrement)

        // Then
        XCTAssertEqual(state.count, 0)
    }
}
```

---

## 🌟 Advantages

1. **Dependency Separation**:  
   - Separates business logic from external dependencies, increasing code flexibility.  
   - Changes to external services do not affect `CounterView.Feature`.

2. **Testability**:  
   - Use mock objects to test without relying on external dependencies like networks.

3. **Extensibility**:  
   - Easily inject various implementations (mock, real service, etc.) at runtime for code reuse.

---

`CounterFeatureDependencyType` follows the Dependency Inversion Principle (DIP), significantly improving code quality and maintainability.
