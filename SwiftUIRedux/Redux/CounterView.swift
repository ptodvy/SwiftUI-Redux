//
//  OcafeBaseViewModel.swift
//  Previewer
//
//  Created by bruno on 1/10/25.
//

import SwiftUI

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

#Preview {
    var dependency = Dependencies(service: Service())
    CounterView(store: .init(
        feature: .init(dependency: dependency),
        initialState: .init(count: 0)
    )).environmentObject(dependency)
}

