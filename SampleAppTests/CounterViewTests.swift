import Testing
@testable import SampleApp

@MainActor
@Suite("CounterView Tests")
struct CounterViewTests {
    
    @Test("View should display initial count")
    func testInitialCount() {
        let mockDependency = MockCounterFeatureDependency()
        let store = Store(
            feature: CounterView.Feature(dependency: mockDependency),
            initialState: CounterView.Feature.State()
        )
        let view = CounterView(store: store)
        
        #expect(view.store.state.count == 0)
    }
    
    @Test("View should display text length")
    func testTextLength() {
        let mockDependency = MockCounterFeatureDependency()
        let store = Store(
            feature: CounterView.Feature(dependency: mockDependency),
            initialState: CounterView.Feature.State(text: "Test", textLength: 4)
        )
        let view = CounterView(store: store)
        
        #expect(view.store.state.textLength == 4)
    }
} 
