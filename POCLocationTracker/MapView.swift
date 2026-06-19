//
//  MapView.swift
//  POCLocationTracker
//
//  Created by Awais Shahid on 03/06/2026.
//

import SwiftUI
import MapKit

struct MapView: View {

	@ObservedObject var locationManager: LocationManager

	let selectedRoute: TrackingSession?

	@State private var cameraPosition: MapCameraPosition = .automatic

	var body: some View {

		Map(position: $cameraPosition) {

			if let route = selectedRoute {

				MapPolyline(
					coordinates: route.points.map {
						CLLocationCoordinate2D(
							latitude: $0.latitude,
							longitude: $0.longitude
						)
					}
				)
				.stroke(
					.blue,
					lineWidth: 8
				)

				if let first = route.points.first {

					Annotation(
						"START",
						coordinate: CLLocationCoordinate2D(
							latitude: first.latitude,
							longitude: first.longitude
						)
					) {

						Image(systemName: "flag.fill")
							.foregroundColor(.green)
					}
				}

				if let last = route.points.last {

					Annotation(
						"END",
						coordinate: CLLocationCoordinate2D(
							latitude: last.latitude,
							longitude: last.longitude
						)
					) {

						Image(systemName: "flag.checkered")
							.foregroundColor(.red)
					}
				}
			}
		}
		.onAppear {

			guard
				let route = selectedRoute,
				let first = route.points.first
			else {
				return
			}

			cameraPosition = .region(
				MKCoordinateRegion(
					center: CLLocationCoordinate2D(
						latitude: first.latitude,
						longitude: first.longitude
					),
					span: MKCoordinateSpan(
						latitudeDelta: 0.01,
						longitudeDelta: 0.01
					)
				)
			)
		}
	}
}
