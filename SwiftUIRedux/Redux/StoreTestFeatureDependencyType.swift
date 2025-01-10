//
//  StoreTestDependencyType.swift
//  Previewer
//
//  Created by bruno on 1/10/25.
//
import Foundation

protocol StoreTestFeatureDependencyType {
    func increment(int: Int) async -> Int
    func decrement(int: Int) async -> Int
}

extension Dependencies: StoreTestFeatureDependencyType {
    func increment(int: Int) async -> Int {
        await service.increment(int: int)
    }
    
    func decrement(int: Int) async -> Int {
        await service.decrement(int: int)
    }
}
