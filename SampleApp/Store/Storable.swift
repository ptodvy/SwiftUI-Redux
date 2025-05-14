//
//  Storable.swift
//  Previewer
//
//  Created by bruno on 1/10/25.
//

import SwiftUI

protocol Storable: View {
    associatedtype Feature: FeatureType
    @MainActor var store: Store<Feature> { get }
}

protocol FeatureType {
    associatedtype State: Sendable
    associatedtype Action: Sendable
    @MainActor func reduce(state: State, action: Action) async -> Self.State
}

protocol BindableAction {
  associatedtype BindingAction
  static func binding(_ action: BindingAction) -> Self
}

@MainActor
class Store<Feature: FeatureType>: ObservableObject {
    
    @Published var state: Feature.State
    private var feature: Feature
    
    init(feature: Feature, initialState state: Feature.State) {
        self.feature = feature
        self.state = state
    }
    
    func send(action: Feature.Action) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            await send(action: action)
        }
    }
    
    func send(action: Feature.Action) async {
        state = await feature.reduce(state: state, action: action)
    }
    
    func binding<T: Equatable>(for keyPath: WritableKeyPath<Feature.State, T>, action: Feature.Action.BindingAction) -> Binding<T> where Feature.Action: BindableAction {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { newValue in
                guard self.state[keyPath: keyPath] != newValue else { return }
                self.state[keyPath: keyPath] = newValue
                self.send(action: .binding(action))
            }
        )
    }
    
    func scope<ScopedFeature: FeatureType>(
        state: WritableKeyPath<Feature.State, ScopedFeature.State>,
        action: @escaping (ScopedFeature.Action) -> Feature.Action,
        feature: ScopedFeature
    ) -> Store<ScopedFeature> {
        ScopedStore(
            parent: self,
            state: state,
            action: action,
            feature: feature
        )
    }
}

@MainActor
private final class ScopedStore<ParentFeature: FeatureType, ScopedFeature: FeatureType>: Store<ScopedFeature> {
    private let parent: Store<ParentFeature>
    private let stateKeyPath: WritableKeyPath<ParentFeature.State, ScopedFeature.State>
    private let transferAction: (ScopedFeature.Action) -> ParentFeature.Action
    
    init(
        parent: Store<ParentFeature>,
        state: WritableKeyPath<ParentFeature.State, ScopedFeature.State>,
        action: @escaping (ScopedFeature.Action) -> ParentFeature.Action,
        feature: ScopedFeature
    ) {
        self.parent = parent
        self.stateKeyPath = state
        self.transferAction = action
        super.init(
            feature: feature,
            initialState: parent.state[keyPath: state]
        )
    }
    
    override func send(action: ScopedFeature.Action) async {
        await super.send(action: action)
        parent.state[keyPath: stateKeyPath] = self.state
        await parent.send(action: transferAction(action))
    }
}
