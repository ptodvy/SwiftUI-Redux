//
//  ContentFeatureTests.swift
//  SampleAppTests
//
//  Created by bruno on 1/10/25.
//

import Testing
@testable import SampleApp

@Suite("ContentFeature Tests")
struct ContentFeatureTests {
    @Test("Increment action should increase count")
    func testIncrementAction() async {
        let feature = ContentView.Feature()
        let initialState = ContentView.Feature.State()
        
        let newState = await feature.reduce(state: initialState, action: .increment)
        
        #expect(newState.count == 1)
    }
    
    @Test("Decrement action should decrease count")
    func testDecrementAction() async {
        let feature = ContentView.Feature()
        let initialState = ContentView.Feature.State()
        
        let newState = await feature.reduce(state: initialState, action: .decrement)
        
        #expect(newState.count == -1)
    }
}
