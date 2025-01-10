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

## 🔗 통합 예제

### **Feature 정의**
```swift
struct CounterFeature: FeatureType {
    struct State {
        var count: Int = 0
    }

    enum Action {
        case increment
        case decrement
    }
    
    var dependency: CounterFeatureDependencyType
        
    init(dependency: CounterFeatureDependencyType) {
        self.dependency = dependency
    }
        
    @MainActor
    func reduce(into state: inout State, action: Action) async {
        switch action {
        case .increment:
            state.count = await dependency.increment(int: state.count)
        case .decrement:
            state.count = await dependency.decrement(int: state.count)
        }
    }
}
```

### **뷰 통합**
```swift
struct CounterView: Storable {
    @EnvironmentObject var dependency: Dependencies
    @StateObject var store: Store<CounterFeature>

    var body: some View {
        VStack {
            Text("Count: \(store.state.count)")
            
            Button("Increment") {
                store.send(action: .increment)
            }
            
            Button("Decrement") {
                store.send(action: .decrement)
            }
        }
    }
}
```

---

## 🎯 주요 기능

- **확장 가능한 상태 관리**:
  `FeatureType`을 준수하는 새로운 상태 관리 로직을 쉽게 추가할 수 있습니다.
- **SwiftUI와의 완벽한 통합**:
  `@Published`와 `@StateObject`를 통해 상태 변경 시 SwiftUI와 즉각적으로 연동됩니다.
- **비동기 작업 처리**:
  async/await를 활용한 현대적인 비동기 작업 처리를 지원합니다.

---


