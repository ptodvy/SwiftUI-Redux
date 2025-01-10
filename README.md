# SwiftUI Redux 프레임워크

이 프로젝트는 SwiftUI에서 Redux 스타일의 상태 관리 시스템을 구현한 예제입니다. 확장성, 테스트 용이성, 사용 편의성을 목표로 설계되었으며, 프로토콜과 제네릭을 활용해 상태 관리와 UI 컴포넌트를 분리합니다.

---

## 📋 개요

프레임워크는 다음과 같은 구성 요소를 포함합니다:

1. **`Storable` 프로토콜**  
   SwiftUI 뷰에 `Store`를 통해 통합하기 위한 표준 인터페이스를 제공합니다.

2. **`FeatureType` 프로토콜**  
   상태와 액션을 정의하고, `reduce` 메서드를 통해 상태 관리 로직을 구현합니다.

3. **`Store` 클래스**  
   상태를 관리하며, 액션을 처리하고 `FeatureType`과 통합합니다.

---

## 🛠️ 주요 구성 요소

### **`Storable` 프로토콜**
```swift
protocol Storable: View {
    associatedtype Feature: FeatureType
    var store: Store<Feature> { get }
}
```

- SwiftUI `View`에 `Store`를 통합하기 위한 프로토콜입니다.
- `Feature`는 반드시 `FeatureType`을 준수해야 합니다.

---

### **`FeatureType` 프로토콜**

`FeatureType` 프로토콜은 Redux 스타일의 상태 관리에서 핵심 역할을 합니다. 상태(State)와 액션(Action)을 정의하고, `reduce` 메서드를 통해 액션에 따라 상태를 변경하는 로직을 제공합니다.

```swift
protocol FeatureType {
    associatedtype State
    associatedtype Action
    @MainActor func reduce(into state: inout State, action: Action) async
}
```

#### **구성 요소**
1. **`State`**  
   - 애플리케이션의 현재 상태를 나타냅니다.  
   - 상태는 구조체로 정의하는 것이 일반적이며, 불변성을 유지합니다.

2. **`Action`**  
   - 사용자 상호작용, 이벤트 또는 기타 상태 변경 요청을 나타냅니다.  
   - 보통 열거형(enum)으로 정의하여 가능한 모든 액션을 명확히 기술합니다.

3. **`reduce` 메서드**  
   - 상태를 변경하는 핵심 로직을 제공합니다.  
   - 특정 액션에 따라 `State`를 수정하며, 비동기 작업(`async`)을 지원합니다.  
   - `@MainActor`를 사용해서 메인 스레드에서 UI 업데이트를 안전하게 수행합니다.

---

### **`Store` 클래스**
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

- **상태 관리**:
  - `@Published`를 사용해 상태 변경 시 SwiftUI와의 빠른 통합을 제공합니다.
- **액션 처리**:
  - 액션을 `reduce` 메서드로 전달하여 상태를 변경합니다.

---

## 🎯 주요 기능

- **확장 가능한 상태 관리**:
  `FeatureType`을 준수하는 새로운 상태 관리 로직을 쉽게 추가할 수 있습니다.
- **SwiftUI와의 완벽한 통합**:
  `@Published`와 `@StateObject`를 통해 상태 변경 시 SwiftUI와 즉각적으로 연동됩니다.
- **비동기 작업 처리**:
  async/await를 활용한 현대적인 비동기 작업 처리를 지원합니다.

---

# SwiftUI Redux 프레임워크에서의 의존성 주입

`CounterFeatureDependencyType`는 Redux 스타일의 상태 관리에서 의존성 주입을 구현하는 데 사용되는 중요한 인터페이스입니다. 
---

## 🔗 의존성 주입 구조

### **`CounterFeatureDependencyType` 프로토콜**

`CounterFeatureDependencyType`은 비즈니스 로직과 외부 의존성을 분리하는 데 사용됩니다. 이를 통해 코드는 더 유연하고 테스트하기 쉬워집니다.

```swift
protocol CounterFeatureDependencyType {
    func increment(int: Int) async -> Int
    func decrement(int: Int) async -> Int
}
```

### **`Dependencies` 확장**

`Dependencies` 객체는 `CounterFeatureDependencyType` 프로토콜을 구현하여 실제 서비스와 연동됩니다.

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

`Dependencies`는 `Service`와의 의존성을 캡슐화하여, 이를 `CounterView.Feature`에서 사용할 수 있도록 제공합니다.

---

## 🔗 통합 예제

`CounterFeatureDependencyType`은 `CounterView.Feature`의 의존성으로 주입됩니다.

### **`CounterView.Feature`에서의 사용**

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

### **미리보기에서 의존성 주입**

미리보기에서는 `Dependencies` 객체를 초기화하여 `CounterView`에 주입합니다.

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

## 🎯 테스트 용이성

### **Mock 구현 예제**

테스트를 위해 `CounterFeatureDependencyType`의 모의(Mock) 구현을 제공합니다.

```swift
class MockCounterFeatureDependency: CounterFeatureDependencyType {
    func increment(int: Int) async -> Int {
        return int + 1 // Mock 동작: 항상 1을 증가
    }

    func decrement(int: Int) async -> Int {
        return int - 1 // Mock 동작: 항상 1을 감소
    }
}
```

### **테스트 코드 예제**

아래는 유닛 테스트를 작성하는 예제입니다.

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

## 🌟 장점

1. **의존성 분리**:
   - 비즈니스 로직과 외부 의존성을 분리하여 코드의 유연성을 높입니다.
   - 외부 서비스 변경 시에도 `CounterView.Feature`에는 영향을 미치지 않습니다.

2. **테스트 가능성**:
   - 모의 객체를 사용하여 외부 의존성 없이도 테스트를 실행할 수 있습니다.
   - 네트워크와 같은 외부 요인에 의존하지 않습니다.

3. **확장성**:
   - 다양한 구현체(Mock, 실제 서비스 등)를 런타임에 주입할 수 있어 코드의 재사용성을 높입니다.

---

`CounterFeatureDependencyType`는 의존성 역전 원칙(DIP)을 준수하여 설계되었으며, 이로 인해 코드의 품질과 유지보수성이 크게 향상됩니다.




