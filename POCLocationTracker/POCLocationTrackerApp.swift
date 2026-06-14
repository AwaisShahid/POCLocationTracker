//
//  POCLocationTrackerApp.swift
//  POCLocationTracker
//
//  Created by Awais Shahid on 03/06/2026.
//

import SwiftUI
import CoreData

@main
struct POCLocationTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
