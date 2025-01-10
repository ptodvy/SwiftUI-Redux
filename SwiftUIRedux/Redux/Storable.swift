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
    var state: State { get }
    @MainActor func reduce(into state: inout State, action: Action) async
}

class Store<Feature: FeatureType>: ObservableObject {
    @Published var state: Feature.State
    private var feature: Feature
    
    init(feature: Feature) {
        self.feature = feature
        self.state = feature.state
    }
    
    @MainActor
    func send(action: Feature.Action) {
        Task {
            await feature.reduce(into: &state, action: action)
        }
    }
}
