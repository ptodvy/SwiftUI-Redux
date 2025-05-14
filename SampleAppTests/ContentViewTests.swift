import Testing
@testable import SampleApp

@MainActor
@Suite("ContentView Tests")
struct ContentViewTests {
    
    @Test
    func testInitialCount() {
        let store = Store(
            feature: ContentView.Feature(),
            initialState: ContentView.Feature.State()
        )
        let view = ContentView(store: store)
        
        #expect(view.store.state.count == 0)
    }
    
    @Test
    func testScoping() async {
        let store = Store(
            feature: ContentView.Feature(),
            initialState: ContentView.Feature.State()
        )
        
        let childStore: Store<CounterView.Feature> = store.scope(
            state: \.counterViewFeature,
            action: ContentView.Feature.Action.counterViewFeature,
            feature: .init(dependency: MockCounterFeatureDependency())
        )
        
        await childStore.send(action: .increment)
        
        #expect(store.state.counterViewFeature.count == 1)
        
        #expect(!store.state.isPresentedCounterView)
        
        await store.send(action: .goToCounterView)
        
        #expect(store.state.isPresentedCounterView)
        
        await childStore.send(action: .delegate(.dismiss))
        
        #expect(!store.state.isPresentedCounterView)
    }
} 
