//
//  LocationPoint.swift
//  POCLocationTracker
//
//  Created by Awais Shahid on 03/06/2026.
//


import Foundation
import CoreLocation
import MapKit

struct LocationPoint: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    let timestamp: Date
}

struct TrackingSession {
    let trigger: String
    var points: [LocationPoint]
}