//
//  CounterViewFeature.swift
//  SampleApp
//
//  Created by bruno on 4/17/25.
//


extension CounterView {
    struct Feature: FeatureType {
        
        struct State {
            var count: Int = 0
            var text: String = ""
            var textLength: Int = 0
        }
        
        enum Action: BindableAction {
            case increment
            case decrement
            case binding(_ action: BindingAction)
        }
        
        enum BindingAction {
            case textChange
        }
        
        var dependency: CounterFeatureDependency
        
        init(dependency: CounterFeatureDependency) {
            self.dependency = dependency
        }
        
        func reduce(into state: inout State, action: Action) async {
            switch action {
            case .increment:
                state.count = await dependency.increment(int: state.count)
            case .decrement:
                state.count = await dependency.decrement(int: state.count)
            case .binding(let BindingAction):
                switch BindingAction {
                case .textChange:
                    state.textLength = state.text.count
                    break
                }
            }
        }
    }
}
