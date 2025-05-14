//
//  CounterViewFeature.swift
//  SampleApp
//
//  Created by bruno on 4/17/25.
//

extension CounterView {
    struct Feature: FeatureType {
        
        struct State: Hashable {
            var count: Int = 0
            var text: String = ""
            var textLength: Int = 0
        }
        
        enum Action: BindableAction {
            case increment
            case decrement
            case binding(_ action: BindingAction)
            case delegate(Delegate)
            
            enum Delegate: Equatable {
                case dismiss
            }
        }
        
        enum BindingAction {
            case textChange
        }
        
        let dependency: CounterFeatureDependency
        
        init(dependency: CounterFeatureDependency) {
            self.dependency = dependency
        }
        
        func reduce(state: State, action: Action) async -> Self.State {
            var newState = state
            
            switch action {
            case .increment:
                newState.count = await dependency.increment(int: state.count)
            case .decrement:
                newState.count = await dependency.decrement(int: state.count)
            case .binding(let BindingAction):
                switch BindingAction {
                case .textChange:
                    newState.textLength = state.text.count
                    break
                }
            case .delegate(_):
                break
            }
            
            return newState
        }
    }
}
