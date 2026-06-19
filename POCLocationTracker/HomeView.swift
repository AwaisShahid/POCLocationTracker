//
//  HomeView.swift
//  POCLocationTracker
//
//  Created by Awais Shahid on 03/06/2026.
//

import SwiftUI

struct HomeView: View {

	@EnvironmentObject var locationManager: LocationManager

	var body: some View {

		NavigationView {

			List {

				Section("Current Status") {

					Text(locationManager.trackingStatus)

					Text(locationManager.activeTrigger)

					Text("\(Int(locationManager.distanceTravelled)) m")
				}

				Section("Completed Routes") {

					ForEach(locationManager.completedRoutes) { route in

						NavigationLink {

							MapView(
								locationManager: locationManager,
								selectedRoute: route
							)

						} label: {

							VStack(alignment: .leading) {

								Text("\(route.startGeofence) → \(route.endGeofence ?? "Unknown")")

								Text("\(route.points.count) points")

								Text(
									"\(Int(route.distance)) meters"
								)
								.font(.caption)
							}
						}
					}
				}
			}
			.navigationTitle("Route Tracker")
			.onAppear {
				locationManager.requestPermission()
			}
		}
		
	}
}
