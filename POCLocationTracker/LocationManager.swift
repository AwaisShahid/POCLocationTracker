//
//  LocationManager.swift
//  POCLocationTracker
//
//  Created by Awais Shahid on 03/06/2026.
//


import Foundation
import CoreLocation
import MapKit
import SwiftUI
import Combine

final class LocationManager: NSObject, ObservableObject {

    private let manager = CLLocationManager()

    @Published var currentLocation: CLLocation?
    @Published var distanceTravelled: Double = 0
    @Published var trackingStatus: String = "Idle"
    @Published var activeTrigger: String = "None"

    @Published var recordedPoints: [LocationPoint] = []

    private var previousLocation: CLLocation?

    private var session: TrackingSession?

    private var isTracking = false

    private var stationaryTimer: Timer?

    private let geofenceCenter = CLLocationCoordinate2D(
        latitude: 37.331161,
        longitude: -122.028295
    )
	
//	37.331161, -122.028295

//	latitude: 37.3349,
//	longitude: -122.0090

    override init() {
        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest

        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
    }

    func requestPermission() {

        manager.requestAlwaysAuthorization()

        manager.startUpdatingLocation()

        startGeofence()
    }

    private func startGeofence() {

        let region = CLCircularRegion(
            center: geofenceCenter,
            radius: 100,
            identifier: "OfficeGeofence"
        )

        region.notifyOnEntry = true
        region.notifyOnExit = true

        manager.startMonitoring(for: region)

        print("📍 Geofence monitoring started")
    }

    func startTracking(trigger: String) {

        guard !isTracking else { return }

        isTracking = true

        activeTrigger = trigger
        trackingStatus = "Tracking"

        recordedPoints.removeAll()

        session = TrackingSession(
            trigger: trigger,
            points: []
        )

        print("▶️ Tracking Started")
        print("Trigger: \(trigger)")
    }

    func stopTracking() {

        guard isTracking else { return }

        isTracking = false

        trackingStatus = "Stopped"

        print("⏹ Tracking Stopped")

        print("""
        Session Summary
        Trigger: \(session?.trigger ?? "")
        Points: \(session?.points.count ?? 0)
        Distance: \(distanceTravelled)m
        """)
    }
}

extension LocationManager: CLLocationManagerDelegate {

	func locationManager(
		_ manager: CLLocationManager,
		didUpdateLocations locations: [CLLocation]
	) {

		guard let location = locations.last else { return }

		currentLocation = location

		if let previous = previousLocation {

			let delta = location.distance(from: previous)

			distanceTravelled += delta

			if distanceTravelled >= 500 &&
				!isTracking {

				startTracking(
					trigger: "500 Meter Walk"
				)
			}
		}

		previousLocation = location

		if isTracking {

			let point = LocationPoint(
				latitude: location.coordinate.latitude,
				longitude: location.coordinate.longitude,
				timestamp: Date()
			)

			recordedPoints.append(point)

			session?.points.append(point)

			print("""
			📌 Recorded
			\(point.latitude)
			\(point.longitude)
			""")
		}

		checkStationary(location)
	}

	func locationManager(
		_ manager: CLLocationManager,
		didEnterRegion region: CLRegion
	) {

		print("✅ Entered Geofence")

		startTracking(
			trigger: "Geofence Entry"
		)
	}

	func locationManager(
		_ manager: CLLocationManager,
		didExitRegion region: CLRegion
	) {

		print("🚪 Exited Geofence")

		stopTracking()
	}
}

private extension LocationManager {

	func checkStationary(
		_ location: CLLocation
	) {

		guard isTracking else { return }

		if location.speed < 0.5 {

			stationaryTimer?.invalidate()

			stationaryTimer = Timer.scheduledTimer(
				withTimeInterval: 300,
				repeats: false
			) { [weak self] _ in

				print("🛑 User stationary 5 min")

				self?.stopTracking()
			}

		} else {

			stationaryTimer?.invalidate()
		}
	}
}
