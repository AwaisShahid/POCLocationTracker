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

	@StateObject private var locationManager = LocationManager(
		context: PersistenceController.shared.container.viewContext
	)

	var body: some Scene {
		WindowGroup {

			HomeView()
				.environmentObject(locationManager)
				.environment(
					\.managedObjectContext,
					persistenceController.container.viewContext
				)
		}
	}
}
