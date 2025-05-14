//
//  ContentView.swift
//  SwiftUIRedux
//
//  Created by bruno on 1/10/25.
//

import SwiftUI

struct ContentView: Storable {
    @EnvironmentObject var dependency: Dependencies
    @StateObject var store: Store<ContentView.Feature>
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("Hello, world! \(store.state.count)")
                
                Button("Go to CounterView") {
                    store.send(action: .goToCounterView)
                }
                
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
                
                
                Text("Child! \(store.state.counterViewFeature.count)")
                Text("Child! \(store.state.counterViewFeature.text)")
            }
            .padding()
            .navigationDestination(isPresented: $store.state.isPresentedCounterView) {
                CounterView(
                    store: store.scope(
                        state: \.counterViewFeature,
                        action: ContentView.Feature.Action.counterViewFeature,
                        feature: .init(dependency: dependency))
                )
            }
        }
    }
}

#Preview {
    ContentView(store: .init(feature: .init(), initialState: .init()))
        .environmentObject(Dependencies(service: Service()))
}
