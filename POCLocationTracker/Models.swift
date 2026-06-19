//
//  LocationPoint.swift
//  POCLocationTracker
//
//  Created by Awais Shahid on 03/06/2026.
//

import Foundation

struct LocationPoint: Identifiable, Codable {
	var id = UUID()
	let latitude: Double
	let longitude: Double
	let timestamp: Date
}

struct GeofencePoint: Identifiable {
	let id: String
	let latitude: Double
	let longitude: Double
	let radius: Double
}

struct RoutePair {
	let startID: String
	let endID: String
}

struct TrackingSession: Identifiable {
	let id = UUID()
	let trigger: String
	let startDate: Date
	var endDate: Date?
	var startGeofence: String
	var endGeofence: String?
	var points: [LocationPoint]
	var distance: Double = 0
}
