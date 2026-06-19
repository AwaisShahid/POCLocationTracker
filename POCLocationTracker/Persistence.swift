//
//  Persistence.swift
//  POCLocationTracker
//
//  Created by Awais Shahid on 03/06/2026.
//

import CoreData

struct PersistenceController {

	static let shared = PersistenceController()

	@MainActor
	static let preview: PersistenceController = {
		PersistenceController(inMemory: true)
	}()

	let container: NSPersistentContainer

	init(inMemory: Bool = false) {

		container = NSPersistentContainer(name: "POCLocationTracker")

		if inMemory {
			container.persistentStoreDescriptions.first?.url =
			URL(fileURLWithPath: "/dev/null")
		}

		container.loadPersistentStores {_, error in
			if let error {
				fatalError(
					"CoreData Error: \(error)"
				)
			}
		}

		container.viewContext.automaticallyMergesChangesFromParent = true
	}
}
