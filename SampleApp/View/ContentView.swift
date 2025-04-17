//
//  ContentView.swift
//  SwiftUIRedux
//
//  Created by bruno on 1/10/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dependency: Dependencies
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                
                Text("Hello, world!")
                
                NavigationLink("Go to CounterView") {
                    let feature = CounterView.Feature(dependency: dependency)
                    CounterView(store: .init(
                        feature: feature,
                        initialState: .init()
                    ))
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Dependencies(service: Service()))
}
