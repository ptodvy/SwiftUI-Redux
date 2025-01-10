//
//  OcafeBaseViewModel.swift
//  Previewer
//
//  Created by bruno on 1/10/25.
//

import SwiftUI

struct StoreTestView: Storable {
    @EnvironmentObject var dependency: Dependencies
    @StateObject var store: Store<StoreTestView.Feature>
    
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

extension StoreTestView {
    struct Feature: FeatureType {
        
        struct State {
            var count: Int
        }
        
        enum Action {
            case increment
            case decrement
        }
        
        var state: State = State(count: 0)
        
        var dependency: StoreTestFeatureDependencyType
        
        init(dependency: StoreTestFeatureDependencyType) {
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
    StoreTestView(store: .init(feature: .init(dependency: dependency)))
        .environmentObject(dependency)
}

