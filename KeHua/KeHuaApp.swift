//
//  KeHuaApp.swift
//  KeHua
//
//  Created by chenxiangxu on 2025/9/17.
//

import SwiftUI
import SwiftData

@main
struct KeHuaApp: App {
    @StateObject private var appState = AppState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                ContentView()
            } else {
                LoginView(isLoggedIn: $appState.isLoggedIn)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn = false
}
