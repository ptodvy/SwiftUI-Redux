//
//  Storable.swift
//  Previewer
//
//  Created by bruno on 1/10/25.
//

import SwiftUI
import Combine

/// A protocol that defines the requirements for a view that uses a store.
/// Views conforming to this protocol can access and manage their state through a store.
protocol Storable: View {
    /// The type of feature that this view uses.
    associatedtype Feature: FeatureType
    /// The store that manages the state for this view.
    @MainActor var store: Store<Feature> { get }
}

/// A protocol that defines the requirements for a feature in the app.
/// Features are responsible for managing their own state and handling actions.
protocol FeatureType {
    /// The type of state that this feature manages.
    associatedtype State: Sendable
    /// The type of actions that this feature can handle.
    associatedtype Action: Sendable
    
    /// Reduces the current state based on the given action.
    /// - Parameters:
    ///   - state: The current state of the feature.
    ///   - action: The action to reduce.
    /// - Returns: The new state after reducing the action.
    @MainActor func reduce(state: State, action: Action) async -> Self.State
}

/// A protocol that defines the requirements for actions that can be bound to UI elements.
protocol BindableAction {
    /// The type of binding action that this action can handle.
    associatedtype BindingAction
    /// Creates a binding action from the given binding action.
    /// - Parameter action: The binding action to create an action from.
    /// - Returns: An action that represents the binding action.
    static func binding(_ action: BindingAction) -> Self
}

/// A class that manages the state for a feature.
/// This class is responsible for storing the state and handling actions.
@MainActor
class Store<Feature: FeatureType>: ObservableObject {
    /// The current state of the feature.
    @Published var state: Feature.State
    /// The feature that this store manages.
    private var feature: Feature
    
    /// Creates a new store with the given feature and initial state.
    /// - Parameters:
    ///   - feature: The feature to manage.
    ///   - state: The initial state of the feature.
    init(feature: Feature, initialState state: Feature.State) {
        self.feature = feature
        self.state = state
    }
    
    /// Sends an action to the feature.
    /// - Parameter action: The action to send.
    func send(action: Feature.Action) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            await send(action: action)
        }
    }
    
    /// Sends an action to the feature asynchronously.
    /// - Parameter action: The action to send.
    func send(action: Feature.Action) async {
        state = await feature.reduce(state: state, action: action)
    }
    
    /// Creates a binding for a property of the state.
    /// - Parameters:
    ///   - keyPath: The key path to the property to bind.
    ///   - action: The binding action to send when the property changes.
    /// - Returns: A binding to the property.
    func binding<T: Equatable>(
        for keyPath: WritableKeyPath<Feature.State, T>,
        action: Feature.Action.BindingAction
    ) -> Binding<T> where Feature.Action: BindableAction {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { newValue in
                guard self.state[keyPath: keyPath] != newValue else { return }
                self.state[keyPath: keyPath] = newValue
                self.send(action: .binding(action))
            }
        )
    }
    
    /// Creates a scoped store for a child feature.
    /// - Parameters:
    ///   - state: The key path to the child feature's state in the parent feature's state.
    ///   - action: A closure that converts child feature actions to parent feature actions.
    ///   - feature: The child feature to create a store for.
    /// - Returns: A store for the child feature.
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

/// A store that manages the state for a child feature.
@MainActor
private final class ScopedStore<Parent: FeatureType, Scoped: FeatureType>: Store<Scoped> {
    /// The parent store that this store is scoped from.
    private let parent: Store<Parent>
    /// The key path to the child feature's state in the parent feature's state.
    private let stateKeyPath: WritableKeyPath<Parent.State, Scoped.State>
    /// A closure that converts child feature actions to parent feature actions.
    private let transferAction: (Scoped.Action) -> Parent.Action
    
    /// Creates a new scoped store.
    /// - Parameters:
    ///   - parent: The parent store to scope from.
    ///   - state: The key path to the child feature's state in the parent feature's state.
    ///   - action: A closure that converts child feature actions to parent feature actions.
    ///   - feature: The child feature to create a store for.
    init(
        parent: Store<Parent>,
        state: WritableKeyPath<Parent.State, Scoped.State>,
        action: @escaping (Scoped.Action) -> Parent.Action,
        feature: Scoped
    ) {
        self.parent = parent
        self.stateKeyPath = state
        self.transferAction = action
        super.init(
            feature: feature,
            initialState: parent.state[keyPath: state]
        )
    }
    
    /// Sends an action to the child feature and updates the parent feature's state.
    /// - Parameter action: The action to send.
    override func send(action: Scoped.Action) async {
        await super.send(action: action)
        parent.state[keyPath: stateKeyPath] = self.state
        await parent.send(action: transferAction(action))
    }
}
