# POCLocationTracker

## Overview

POCLocationTracker is a Proof of Concept (POC) iOS application built using:

* Swift
* SwiftUI
* CoreLocation
* MapKit
* CoreData

The application demonstrates:

* Geofence monitoring
* Automatic route tracking
* Background location updates
* Route recording
* Route visualization using MapPolyline
* Persistent storage of completed routes using CoreData

---

# How It Works

## Geofences

The app continuously monitors configured geofence locations.

Example:

| Location  | Latitude  | Longitude   |
| --------- | --------- | ----------- |
| Office    | 37.335261 | -122.032049 |
| Airport   | 37.334708 | -122.068077 |
| Warehouse | 37.3360   | -122.0200   |

Each location is monitored using:

```swift
CLCircularRegion
```

---

## Route Pairs

The application uses fixed route pairs.

Example:

```swift
Office -> Airport
Airport -> Warehouse
```

A route only ends when its configured destination is reached.

Example:

### Valid

```text
Enter Office
↓
Tracking Starts
↓
Enter Airport
↓
Tracking Stops
```

### Invalid

```text
Enter Office
↓
Tracking Starts
↓
Enter Warehouse
↓
Tracking Continues
```

Warehouse is not the configured destination for Office.

---

## Tracking Flow

### Step 1

User enters a configured geofence.

Example:

```text
Office
```

### Step 2

Tracking automatically starts.

The app:

* Starts GPS updates
* Creates a new TrackingSession
* Records route points

### Step 3

Location updates are received.

Each GPS coordinate is saved as:

```swift
LocationPoint
```

Example:

```swift
struct LocationPoint {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
}
```

### Step 4

User enters the configured destination geofence.

Example:

```text
Airport
```

Tracking automatically stops.

### Step 5

Route is saved to CoreData.

---

# Data Models

## GeofencePoint

```swift
struct GeofencePoint {

    let id: String

    let latitude: Double

    let longitude: Double

    let radius: Double
}
```

Represents a monitored location.

---

## RoutePair

```swift
struct RoutePair {

    let startID: String

    let endID: String
}
```

Defines valid start and destination pairs.

---

## LocationPoint

```swift
struct LocationPoint: Codable {

    let latitude: Double

    let longitude: Double

    let timestamp: Date
}
```

Represents a recorded GPS point.

---

## TrackingSession

```swift
struct TrackingSession {

    let trigger: String

    let startDate: Date

    var endDate: Date?

    var startGeofence: String

    var endGeofence: String?

    var points: [LocationPoint]

    var distance: Double
}
```

Represents a completed route.

---

# Home Screen

Displays:

* Tracking Status
* Active Trigger
* Distance Travelled
* Completed Routes

Each completed route displays:

```text
Start Location -> End Location
Point Count
Distance
```

Selecting a route opens MapView.

---

# Map Screen

Displays:

* Recorded route polyline
* Start marker
* End marker

Uses:

```swift
MapPolyline
```

for route rendering.

Uses:

```swift
Annotation
```

for start/end markers.

---

# CoreData Storage

Completed routes are saved using:

```swift
RouteEntity
```

Stored fields:

* id
* trigger
* startDate
* endDate
* startGeofence
* endGeofence
* distance
* pointsJSON

GPS points are serialized using:

```swift
JSONEncoder
```

and stored as JSON.

---

# Required Permissions

Add to Info.plist:

```xml
NSLocationWhenInUseUsageDescription
```

Example:

```text
Location access is required to monitor routes.
```

---

```xml
NSLocationAlwaysAndWhenInUseUsageDescription
```

Example:

```text
Location access is required to monitor routes in the background.
```

---

# Background Modes

Enable:

Target
→ Signing & Capabilities
→ Background Modes

Check:

```text
Location updates
```

---

# Testing on Simulator

## Open Simulator

Run the application.

---

## Start Location Simulation

In Simulator menu:

```text
Features
→ Location
→ Freeway Drive
```

This simulates continuous movement.

---

Alternative options:

```text
Features
→ Location
→ City Bicycle Ride
```

```text
Features
→ Location
→ City Run
```

```text
Features
→ Location
→ Custom GPX Route
```

---

## Observe Logs

Xcode Console should display:

```text
 Entered Office
```

```text
Tracking Started
```

```text
didUpdateLocations
```

```text
Recorded
37.xxxxx
-122.xxxxx
```

---

When destination is reached:

```text
🏁 Destination Reached
```

```text
Route Saved
```

```text
Route Saved
```

---

# Testing on Real Device

1. Install app on iPhone.
2. Grant "Always Allow" location permission.
3. Enable Background Location Updates.
4. Physically move between configured geofences.
5. Observe route creation and storage.

---

# Expected Result

The application automatically:

1. Monitors geofences.
2. Starts tracking when entering a valid start location.
3. Records GPS coordinates.
4. Stops tracking when reaching the configured destination.
5. Saves the completed route.
6. Displays the route on a map using a polyline.

