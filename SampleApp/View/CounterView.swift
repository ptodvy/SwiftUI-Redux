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

#Preview {
    let dependency = Dependencies(service: Service())
    CounterView(store: .init(
        feature: .init(dependency: dependency),
        initialState: .init()
    )).environmentObject(dependency)
}

