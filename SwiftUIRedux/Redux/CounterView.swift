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
        VStack {
            Spacer()
            
            TextField("", text: store.binding(for: \.text, action: .textChange))
                .padding(.leading, 8)
                .frame(height: 44)
                .border(Color.blue)
            
            Text("textLength: \(store.state.textLength)")
            
            Text("text: \(store.state.text)")

            Divider()
            
            HStack {
                Button("Increment") {
                    store.send(action: .increment)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Decrement") {
                    store.send(action: .decrement)
                }
                .buttonStyle(.borderedProminent)
            }
            
            Text("count: \(store.state.count)")
            
            Spacer()
        }
        .padding(18)
    }
}

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

#Preview {
    var dependency = Dependencies(service: Service())
    CounterView(store: .init(
        feature: .init(dependency: dependency),
        initialState: .init()
    )).environmentObject(dependency)
}

