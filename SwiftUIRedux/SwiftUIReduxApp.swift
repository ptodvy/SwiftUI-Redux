//
//  SwiftUIReduxApp.swift
//  SwiftUIRedux
//
//  Created by bruno on 1/10/25.
//

import SwiftUI

@main
struct SwiftUIReduxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Dependencies(service: Service()))
        }
    }
}
