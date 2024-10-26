//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Adam Makowski on 20/08/2024.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(HomeViewModel())
        }
    }
}
