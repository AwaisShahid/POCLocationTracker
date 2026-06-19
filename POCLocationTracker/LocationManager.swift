//
//  LocationManager.swift
//  POCLocationTracker
//
//  Created by Awais Shahid on 03/06/2026.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine
import CoreData

final class LocationManager: NSObject, ObservableObject {

	private let manager = CLLocationManager()
	private let context: NSManagedObjectContext
	
	private var previousLocation: CLLocation?
	private var session: TrackingSession?
	private var isTracking = false
	private var expectedDestination: GeofencePoint?
	private var monitoringStarted = false
	
	@Published var currentLocation: CLLocation?
	@Published var distanceTravelled: Double = 0
	@Published var trackingStatus: String = "Idle"
	@Published var activeTrigger: String = "None"
	@Published var recordedPoints: [LocationPoint] = []
	
	init(context: NSManagedObjectContext) {

		self.context = context

		super.init()

		manager.delegate = self
		manager.desiredAccuracy = kCLLocationAccuracyBest

		manager.allowsBackgroundLocationUpdates = true
		manager.pausesLocationUpdatesAutomatically = false
		
		loadRoutes()
	}
	
	deinit {

		manager.stopUpdatingLocation()

		for region in manager.monitoredRegions {

			manager.stopMonitoring(for: region)
		}
	}
	
	private let validRoutes: [RoutePair] = [

		RoutePair(
			startID: "Office",
			endID: "Airport"
		),

		RoutePair(
			startID: "Airport",
			endID: "Warehouse"
		)
	]
	
	let geofences: [GeofencePoint] = [

		GeofencePoint(
			id: "Office",
			latitude: 37.335261,
			longitude: -122.032049,
			radius: 50
		),

		GeofencePoint(
			id: "Airport",
			latitude: 37.334708,
			longitude: -122.068077,
			radius: 50
		),

		GeofencePoint(
			id: "Warehouse",
			latitude: 37.3360,
			longitude: -122.0200,
			radius: 50
		)
	]
	
	@Published var completedRoutes: [TrackingSession] = []
	
	func requestPermission() {

		manager.requestAlwaysAuthorization()

		guard !monitoringStarted else { return }

		monitoringStarted = true

		startGeofenceMonitoring()
	}
	
	private func geofenceFor(identifier: String) -> GeofencePoint? {

		geofences.first {
			$0.id == identifier
		}
	}

	private func routeFor(startID: String) -> RoutePair? {

		validRoutes.first {
			$0.startID == startID
		}
	}

	private func startGeofenceMonitoring() {

		for fence in geofences {

			let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: fence.latitude, longitude: fence.longitude), radius: fence.radius, identifier: fence.id)

			region.notifyOnEntry = true
			region.notifyOnExit = true

			manager.startMonitoring(for: region)
		}
	}

	func startTracking(trigger: String, startGeofence: String) {

		guard !isTracking else { return }
		
		manager.startUpdatingLocation()
		manager.requestLocation()
		
		distanceTravelled = 0
		recordedPoints.removeAll()
		previousLocation = nil

		isTracking = true

		activeTrigger = trigger
		trackingStatus = "Tracking"

		recordedPoints.removeAll()

		session = TrackingSession(
			trigger: trigger,
			startDate: Date(),
			endDate: nil,
			startGeofence: startGeofence,
			endGeofence: nil,
			points: [],
			distance: 0
		)

		print("Tracking Started")
		print("Trigger: \(trigger)")
	}

	func stopTracking() {

		guard isTracking else { return }
		
		manager.stopUpdatingLocation()

		isTracking = false

		trackingStatus = "Stopped"

		session?.endDate = Date()

		if let session {

			completedRoutes.insert(
				session,
				at: 0
			)

			saveRoute(session)
		}

		print("Route Saved")
		print("Points: \(session?.points.count ?? 0)")

		distanceTravelled = 0
		self.session = nil
	}
	
	private func saveRoute(_ route: TrackingSession) {

		let entity = RouteEntity(context: context)

		entity.id = route.id
		entity.trigger = route.trigger
		entity.startDate = route.startDate
		entity.endDate = route.endDate
		entity.distance = route.distance
		entity.startGeofence = route.startGeofence
		entity.endGeofence = route.endGeofence

		do {
			let data = try JSONEncoder().encode(route.points)
			entity.pointsJSON = String(
				data: data,
				encoding: .utf8
			)
		
			print("Saving \(route.points.count) points")

			try context.save()

			print("✅ Route Saved")

		} catch {
			print(error)
		}
	}
	
	func loadRoutes() {

		let request: NSFetchRequest<RouteEntity> =
			RouteEntity.fetchRequest()

		request.sortDescriptors = [
			NSSortDescriptor(key: "startDate", ascending: false)
		]

		do {

			let routes = try context.fetch(request)

			completedRoutes = routes.compactMap { route -> TrackingSession? in

				guard
					let trigger = route.trigger,
					let startDate = route.startDate,
					let json = route.pointsJSON,
					let data = json.data(using: .utf8),
					let points = try? JSONDecoder()
						.decode(
							[LocationPoint].self,
							from: data
						)
				else {
					return nil
				}

				print("Loaded Route")
				print("Trigger: \(trigger)")
				print("Points: \(points.count)")

				return TrackingSession(
					trigger: trigger,
					startDate: startDate,
					endDate: route.endDate,
					startGeofence: route.startGeofence ?? trigger,
					endGeofence: route.endGeofence,
					points: points,
					distance: route.distance
				)
			}

		} catch {

			print(error)
		}
	}
}

extension LocationManager: CLLocationManagerDelegate {
	
	func locationManagerDidChangeAuthorization(
		_ manager: CLLocationManager
	) {

		print("Authorization = \(manager.authorizationStatus.rawValue)")

		switch manager.authorizationStatus {

		case .authorizedAlways:

			print("Authorized Always")

		case .authorizedWhenInUse:

			print("Only When In Use")

		case .denied:

			print("Denied")

		default:
			break
		}
	}
	
	func locationManager(
		_ manager: CLLocationManager,
		didUpdateLocations locations: [CLLocation]
	) {

		print("📍 didUpdateLocations")

		guard let location = locations.last else { return }

		currentLocation = location

		if let previous = previousLocation {

			let delta = location.distance(from: previous)

			distanceTravelled += delta

			session?.distance = distanceTravelled
		}

		previousLocation = location

		guard isTracking else { return }

		let point = LocationPoint(
			latitude: location.coordinate.latitude,
			longitude: location.coordinate.longitude,
			timestamp: Date()
		)

		recordedPoints.append(point)

		session?.points.append(point)

		print("""
		Recorded
		\(point.latitude)
		\(point.longitude)
		""")
	}
	
	func locationManager(
		_ manager: CLLocationManager,
		didFailWithError error: Error
	) {

		print("Location Error")
		print(error.localizedDescription)
	}
	
	func locationManager(
		_ manager: CLLocationManager,
		didEnterRegion region: CLRegion
	) {

		print("Entered \(region.identifier)")

		if !isTracking {

			guard let route =
				routeFor(startID: region.identifier)
			else {
				print("No route configured")
				return
			}

			expectedDestination =
				geofenceFor(
					identifier: route.endID
				)

			startTracking(
				trigger: "Journey",
				startGeofence: region.identifier
			)

			print("Destination = \(route.endID)")

			return
		}

		guard let destination =
			expectedDestination
		else {
			return
		}

		if region.identifier == destination.id {

			print("Destination Reached")

			session?.endGeofence =
				destination.id

			stopTracking()
		}
	}

	func locationManager(
		_ manager: CLLocationManager,
		didExitRegion region: CLRegion
	) {

		print("Exited \(region.identifier)")
	}
}
