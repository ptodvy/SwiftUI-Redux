//
//  CounterFeatureTests.swift
//  SampleAppTests
//
//  Created by bruno on 1/10/25.
//

import Testing
@testable import SampleApp

@MainActor
struct CounterFeatureTests {
    
    @Test func testIncrementAction() async throws {
        let store = Store<CounterView.Feature>(feature: .init(dependency: MockCounterFeatureDependency()), initialState: .init())
        
        await store.send(action: .increment)
        
        #expect(store.state.count == 1)
    }
    
    @Test
    func testDecrementAction() async throws {
        let store = Store<CounterView.Feature>(feature: .init(dependency: MockCounterFeatureDependency()), initialState: .init())
        
        await store.send(action: .decrement)
        
        #expect(store.state.count == -1)
    }
    
    @Test
    func testEditText() async throws {
        // Arrange
        let store = Store<CounterView.Feature>(feature: .init(dependency: MockCounterFeatureDependency()), initialState: .init())
        
        let bindValue = store.binding(for: \.text, action: .textChange)
        bindValue.wrappedValue = "testEditText"
        
        #expect(store.state.text == "testEditText")
        try await Task.sleep(for: .milliseconds(100))
        #expect(store.state.textLength == "testEditText".count)
    }
}
