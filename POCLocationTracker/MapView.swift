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

    var body: some View {

        Map {

            UserAnnotation()

            MapCircle(
                center: CLLocationCoordinate2D(
                    latitude: 37.3349,
                    longitude: -122.0090
                ),
                radius: 100
            )

            MapPolyline(
                coordinates:
                    locationManager.recordedPoints.map {
                        CLLocationCoordinate2D(
                            latitude: $0.latitude,
                            longitude: $0.longitude
                        )
                    }
            )
        }
    }
}