//
//  CounterDependencyType.swift
//  Previewer
//
//  Created by bruno on 1/10/25.
//
import Foundation

protocol CounterFeatureDependency: Sendable {
    func increment(int: Int) async -> Int
    func decrement(int: Int) async -> Int
}

extension Dependencies: CounterFeatureDependency {
    func increment(int: Int) async -> Int {
        await service.increment(int: int)
    }
    
    func decrement(int: Int) async -> Int {
        await service.decrement(int: int)
    }
}

final class MockCounterFeatureDependency: CounterFeatureDependency {
    func increment(int: Int) async -> Int {
        return int + 1
    }
 
    func decrement(int: Int) async -> Int {
        return int - 1
    }
}

