//
//  ContentView.swift
//  SwiftUIRedux
//
//  Created by bruno on 1/10/25.
//

import SwiftUI
import Combine

struct ContentView: Storable {
    @EnvironmentObject var dependency: Dependencies
    @EnvironmentObject var pathStore: PathStore
    @StateObject var store: Store<ContentView.Feature>
    
    var body: some View {
        NavigationStack(path: $pathStore.path) {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("Hello, world! \(store.state.count)")
                
                Button("Go to CounterView") {
                    pathStore.navigate(to: .counter)
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
            }
            .padding()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .counter:
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
}

#Preview {
    ContentView(store: .init(feature: .init(), initialState: .init()))
        .environmentObject(Dependencies(service: Service()))
}
