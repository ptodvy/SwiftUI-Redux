//
//  Storable.swift
//  Previewer
//
//  Created by bruno on 1/10/25.
//

import SwiftUI

protocol Storable: View {
    associatedtype Feature: FeatureType
    var store: Store<Feature> { get }
}

protocol FeatureType {
    associatedtype State
    associatedtype Action
    @MainActor func reduce(into state: inout State, action: Action) async
}

protocol BindableAction {
  associatedtype BindingAction
  static func binding(_ action: BindingAction) -> Self
}

final class Store<Feature: FeatureType>: ObservableObject {
    @Published var state: Feature.State
    private var feature: Feature
    
    init(feature: Feature, initialState state: Feature.State) {
        self.feature = feature
        self.state = state
    }
    
    @MainActor
    func send(action: Feature.Action) {
        Task {
            await feature.reduce(into: &state, action: action)
        }
    }
    
    func send(action: Feature.Action) async {
        await feature.reduce(into: &state, action: action)
    }
    
    func binding<T: Equatable>(for keyPath: WritableKeyPath<Feature.State, T>, action: Feature.Action.BindingAction) -> Binding<T> where Feature.Action: BindableAction {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { newValue in
                guard self.state[keyPath: keyPath] != newValue else { return }
                self.state[keyPath: keyPath] = newValue
                Task {
                    await self.send(action: .binding(action))
                }
            }
        )
    }
}
