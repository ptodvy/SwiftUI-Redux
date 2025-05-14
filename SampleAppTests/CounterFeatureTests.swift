//
//  CounterFeatureTests.swift
//  SampleAppTests
//
//  Created by bruno on 1/10/25.
//

import Testing
@testable import SampleApp

@Suite("CounterFeature Tests")
struct CounterFeatureTests {
    @Test("Increment action should increase count")
    func testIncrementAction() async {
        let mockDependency = MockCounterFeatureDependency()
        let feature = CounterView.Feature(dependency: mockDependency)
        let initialState = CounterView.Feature.State()
        
        let newState = await feature.reduce(state: initialState, action: .increment)
        
        #expect(newState.count == 1)
    }
    
    @Test("Decrement action should decrease count")
    func testDecrementAction() async {
        let mockDependency = MockCounterFeatureDependency()
        let feature = CounterView.Feature(dependency: mockDependency)
        let initialState = CounterView.Feature.State()
        
        let newState = await feature.reduce(state: initialState, action: .decrement)
        
        #expect(newState.count == -1)
    }
    
    @Test("Text change action should update text length")
    func testTextChangeAction() async {
        let mockDependency = MockCounterFeatureDependency()
        let feature = CounterView.Feature(dependency: mockDependency)
        let initialState = CounterView.Feature.State(text: "Test")
        
        let newState = await feature.reduce(state: initialState, action: .binding(.textChange))
        
        #expect(newState.textLength == 4)
    }
}
