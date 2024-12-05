import Foundation
import CoreLocation
import UserNotifications
import FirebaseFirestore

// A singleton class responsible for managing geolocation, geofencing, and beacon monitoring.
class GeolocationManager: NSObject, CLLocationManagerDelegate {
    let CampusUUID = UUID(uuidString: "8D5DB264-E6E0-49EC-A1DD-A8E8080E1F43")
    
    // Shared instance of GeolocationManager to ensure a single point of access
    static let shared = GeolocationManager()
    
    // The CLLocationManager instance used for location services
    private var locationManager: CLLocationManager?
    
    // Stores geofenced regions being monitored
    private var monitoredRegions: [CLCircularRegion] = []
    
    // Stores beacon regions being monitored
    private var beaconRegions: [CLBeaconRegion] = []
    
    // Tracks the last time a notification was sent to prevent spamming
    private var lastNotificationTime: Date?
    
    // Stores the current location of the user
    var currentLocation: CLLocation?

    // Private initializer to enforce the singleton pattern
    private override init() {
        super.init()
        setupLocationManager()
    }

    // MARK: - Location Manager Setup

    // Configures the CLLocationManager and requests necessary permissions.
    private func setupLocationManager() {

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 10
        
            locationManager?.requestWhenInUseAuthorization()
        
    }
    //MARK: - Beacon Ranging
    // Starts beacon ranging for a specific major and minor combination.
        func startBeaconRanging(for major: CLBeaconMajorValue, minor: CLBeaconMinorValue) {
            guard let campusUUID = CampusUUID else {
                print("DEBUG: Invalid campus UUID.")
                return
            }

            // Create a constraint for the specific beacon
            let beaconConstraint = CLBeaconIdentityConstraint(uuid: campusUUID, major: major, minor: minor)

            // Start ranging for this beacon
            locationManager?.startRangingBeacons(satisfying: beaconConstraint)
            print("DEBUG: Started ranging for beacon with major \(major) and minor \(minor).")
        }

    // MARK: - Authorization Handling

    // Handles changes in location authorization status.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus(manager.authorizationStatus)
    }

    // Processes the current authorization status and initiates location updates if permitted.
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("DEBUG: Location services are restricted or denied.")
            showAlert(title: "Location Error", message: "Please enable location services in Settings.")
        case .authorizedWhenInUse, .authorizedAlways:
            print("DEBUG: Location services authorized.")
            locationManager?.startUpdatingLocation()
            setupGeofencing()
        @unknown default:
            fatalError("DEBUG: Unknown location authorization status.")
        }
    }

    // MARK: - Location Updates

    // Updates the current location when a location update is received.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("DEBUG: No location data received.")
            return
        }
        currentLocation = location
        print("DEBUG: Current location updated to \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    // MARK: - Geofencing

    // Sets up geofencing regions for buildings stored in Firestore.
     func setupGeofencing() {
        let firestore = Firestore.firestore()
        firestore.collection("buildings").getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("DEBUG: Error fetching buildings: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            documents.forEach { document in
                if let region = self?.createGeofenceRegion(from: document) {
                    self?.monitoredRegions.append(region)
                    self?.locationManager?.startMonitoring(for: region)
                }
            }
        }
    }

    // Creates a geofence region based on building data from Firestore.
    private func createGeofenceRegion(from document: QueryDocumentSnapshot) -> CLCircularRegion? {
        let data = document.data()
        guard let name = data["name"] as? String,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double else { return nil }

        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: 100, identifier: name)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        print("DEBUG: Geofence created for \(name)")
        return region
    }

    // Handles events when the user enters a geofenced region.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        sendNotification(title: "Welcome!", body: "You are near \(circularRegion.identifier).")
        
        // Find the selected room associated with the building
            if let selectedRoom = RoomsViewController.selectedRoom, selectedRoom.buildingID == circularRegion.identifier {
                // Start beacon ranging for the room
                startBeaconRanging(for: selectedRoom.major, minor: selectedRoom.minor)
                sendNotification(title: "You have arrived!", body: "Indoor navigation has started for \(selectedRoom.name).")
            }
    }

    // Handles events when the user exits a geofenced region.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        sendNotification(title: "Goodbye!", body: "You have left \(circularRegion.identifier).")
    }

    // MARK: - Beacon Monitoring

    // Sets up a beacon region for indoor navigation within a building.
    func setupBeaconRegion(for buildingName: String) {
        let firestore = Firestore.firestore()
        firestore.collection("buildings").document(buildingName).getDocument { [weak self] (document, error) in
            guard let data = document?.data(), error == nil else {
                print("DEBUG: Error fetching building details: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

           
            guard let campusUUID = self?.CampusUUID,
                  let majorValue = data["major"] as? CLBeaconMajorValue else {
                print("DEBUG: Invalid beacon data.")
                return
            }
            // create a beacon region

            let beaconRegion = CLBeaconRegion(uuid: campusUUID, major: majorValue, identifier: buildingName)
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true

            self?.beaconRegions.append(beaconRegion)// add the beacon to the list of monitored beacons
            self?.locationManager?.startMonitoring(for: beaconRegion)// start monitoring for it
            self?.locationManager?.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: campusUUID, major: majorValue))// start ranging for the region
            print("DEBUG: Beacon region created for \(buildingName).")
        }
    }
    

    // Handles beacon proximity events and sends proximity-based notifications.
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
            guard let nearestBeacon = beacons.first else { return }
            let now = Date()

            if let lastTime = lastNotificationTime, now.timeIntervalSince(lastTime) < 10 {
                return // Avoid spamming notifications
            }
            lastNotificationTime = now

            let major = nearestBeacon.major.intValue
            let minor = nearestBeacon.minor.intValue
            print("DEBUG: Detected beacon - Major: \(major), Minor: \(minor)")

            handleBeaconProximity(nearestBeacon)
        }

        // Processes beacon proximity and provides notifications based on distance.
        private func handleBeaconProximity(_ beacon: CLBeacon) {
            switch beacon.proximity {
            case .immediate:
                sendNotification(title: "You have arrived!", body: "You are right at the facility.")
            case .near:
                sendNotification(title: "Almost there!", body: "The facility is just ahead.")
            case .far:
                sendNotification(title: "Keep going!", body: "The facility is further away.")
            default:
                print("DEBUG: Unknown beacon proximity.")
            }
        }

    // MARK: - Notifications

    // Sends a local notification to the user.
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG: Error adding notification: \(error.localizedDescription)")
            }
        }
    }

    // Finds the top visible view controller for presenting alerts.
    func getTopViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController {
            return getTopViewController(base: tab.selectedViewController)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }

    // Presents an alert to the user.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        DispatchQueue.main.async {
            if let topViewController = self.getTopViewController() {
                topViewController.present(alert, animated: true, completion: nil)
            } else {
                print("DEBUG: Unable to find a visible view controller to present the alert.")
            }
        }
    }
}
