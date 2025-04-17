//
//  Dependencies.swift
//  Previewer
//
//  Created by bruno on 1/10/25.
//

import SwiftUI

/// environmentObject로 사용할 ObservableObject
class Dependencies: ObservableObject {
    // Network
    var service: ServiceType
    
    init(service: ServiceType) {
        self.service = service
    }
}

protocol ServiceType {
    func increment(int: Int) async -> Int
    func decrement(int: Int) async -> Int
}

struct Service: ServiceType {
    func increment(int: Int) async -> Int {
        var int = int
        int += 1
        return int
    }
    
    func decrement(int: Int) async -> Int {
        var int = int
        int -= 1
        return int
    }
}
