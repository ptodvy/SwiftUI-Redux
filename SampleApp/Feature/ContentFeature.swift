//
//  ContentFeature.swift
//  SampleApp
//
//  Created by bruno on 5/14/25.
//

extension ContentView {
    struct Feature: FeatureType {
        struct State {
            var count: Int = 0
            var isPresentedCounterView: Bool = false
            var counterViewFeature: CounterView.Feature.State = .init()
        }
        
        enum Action {
            case increment
            case decrement
            case goToCounterView
            case counterViewFeature(CounterView.Feature.Action)
        }
        
        func reduce(state: State, action: Action) async -> Self.State {
            var newState = state
            switch action {
            case .increment:
                newState.count += 1
                newState.counterViewFeature.count = newState.count
            case .decrement:
                newState.count -= 1
                newState.counterViewFeature.count = newState.count
            case .goToCounterView:
                newState.isPresentedCounterView = true
            case .counterViewFeature(let action):
                switch action {
                case .delegate(let delegateAction):
                    switch delegateAction {
                    case .dismiss:
                        newState.isPresentedCounterView = false
                    }
                default:
                    break
                }
            }
            return newState
        }
    }
}
