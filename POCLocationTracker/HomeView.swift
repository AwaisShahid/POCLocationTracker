//
//  HomeView.swift
//  POCLocationTracker
//
//  Created by Awais Shahid on 03/06/2026.
//


import SwiftUI
import CoreLocation

struct HomeView: View {

    @StateObject var locationManager = LocationManager()

    var body: some View {

        NavigationView {

            VStack(spacing: 20) {

                Text("Latitude")
                Text(
                    "\(locationManager.currentLocation?.coordinate.latitude ?? 0)"
                )

                Text("Longitude")
                Text(
                    "\(locationManager.currentLocation?.coordinate.longitude ?? 0)"
                )

                Text("Speed")
                Text(
                    "\(locationManager.currentLocation?.speed ?? 0)"
                )

                Text("Distance")
                Text(
                    "\(Int(locationManager.distanceTravelled)) meters"
                )

                Text("Status")
                Text(locationManager.trackingStatus)

                Text("Trigger")
                Text(locationManager.activeTrigger)

                Button("Simulate Start Tracking") {

                    locationManager.startTracking(
                        trigger: "Manual"
                    )
                }

                Button("Simulate Stop Tracking") {

                    locationManager.stopTracking()
                }

                NavigationLink("Open Map") {

                    MapView(
                        locationManager: locationManager
                    )
                }
            }
            .padding()
            .onAppear {

                locationManager.requestPermission()
            }
        }
    }
}
