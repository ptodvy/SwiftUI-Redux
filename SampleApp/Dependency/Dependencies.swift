//
//  Dependencies.swift
//  Previewer
//
//  Created by bruno on 1/10/25.
//

import SwiftUI


// 예시용 화면 타입 정의
enum Route: Hashable {
    case counter
}

class PathStore: ObservableObject {
    @Published var path: NavigationPath = .init()
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
        
    func goRoot() {
        path.removeLast(path.count)
    }
    
    init(path: NavigationPath = .init()) {
        self.path = path
    }
}


final class Dependencies: Sendable, ObservableObject {
    let service: ServiceType
    
    init(service: ServiceType) {
        self.service = service
    }
}

protocol ServiceType: Sendable {
    func increment(int: Int) async -> Int
    func decrement(int: Int) async -> Int
}

struct Service: ServiceType {
    func increment(int: Int) async -> Int {
        return await Task.detached {
            var result = int
            result += 1
            return result
        }.value
    }
    
    func decrement(int: Int) async -> Int {
        return await Task.detached {
            var int = int
            int -= 1
            return int
        }.value
    }
}
