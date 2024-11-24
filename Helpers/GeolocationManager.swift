import Foundation
import CoreLocation
import UserNotifications
import FirebaseFirestore

class GeolocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = GeolocationManager()  // Singleton instance
    
    private var locationManager: CLLocationManager?
    private var monitoredRegions: [CLCircularRegion] = []
    var currentLocation: CLLocation?  // Stores the user's current location
    private var beaconRegions: [CLBeaconRegion] = []  // To manage indoor beacons
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
          locationManager = CLLocationManager()
          locationManager?.delegate = self
          locationManager?.desiredAccuracy = kCLLocationAccuracyBest
          locationManager?.distanceFilter = 10 // Adjust distance filter as needed

          // Do NOT request authorization here; wait for locationManagerDidChangeAuthorization callback
          locationManager?.startUpdatingLocation() // Start updating location after setting up the location manager
      }
      
      // CLLocationManagerDelegate method to handle changes in location authorization
      func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
          switch manager.authorizationStatus {
          case .notDetermined:
              // The user has not yet made a choice regarding location authorization
              manager.requestAlwaysAuthorization() // Request Always Authorization for geofencing
          case .restricted, .denied:
              // Location services are restricted or denied
              print("DEBUG: Location services are restricted or denied.")
          case .authorizedWhenInUse, .authorizedAlways:
              // Location services are authorized
              manager.startUpdatingLocation()
              let firestore = Firestore.firestore() // Get the Firestore reference
                     setupGeofencing(for: firestore, collection: "buildings") 
          @unknown default:
              fatalError("Unknown location authorization status.")
          }
      }
    
    // Set up geofencing regions for buildings
    func setupGeofencing(for db: Firestore, collection: String) {
        db.collection(collection).getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("DEBUG: Error fetching buildings: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            documents.forEach { document in
                let buildingData = document.data()
                if let name = buildingData["name"] as? String,
                   let latitude = buildingData["latitude"] as? Double,
                   let longitude = buildingData["longitude"] as? Double {
                    
                    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: 200, identifier: name)
                    region.notifyOnEntry = true
                    region.notifyOnExit = true
                    
                    self?.monitoredRegions.append(region)
                    self?.locationManager?.startMonitoring(for: region)  // Start monitoring the region
                }
            }
        }
    }
    
    ///Beacons///
    ///integrating beacons for indoor navigation
    // Set up indoor beacon monitoring based on beacon UUID from Firestore
        func setupBeaconRegion(forBuilding buildingName: String, db: Firestore) {
            db.collection("buildings").document(buildingName).getDocument { [weak self] (document, error) in
                guard let buildingData = document?.data(), error == nil else {
                    print("DEBUG: Error fetching building details: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                if let uuidString = buildingData["beaconUUID"] as? String,
                   let uuid = UUID(uuidString: uuidString) {
                    let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: buildingName)
                    beaconRegion.notifyOnEntry = true
                    beaconRegion.notifyOnExit = true
                    
                    self?.beaconRegions.append(beaconRegion)
                    self?.locationManager?.startMonitoring(for: beaconRegion)
                    self?.locationManager?.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: uuid))
                } else {
                    print("DEBUG: No valid beacon UUID found for building: \(buildingName)")
                }
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let nearestBeacon = beacons.first {
            switch nearestBeacon.proximity {
            case .immediate:
                sendBeaconNotification(title: "You have arrived!", body: "You are right at the facility.")
            case .near:
                sendBeaconNotification(title: "Almost there!", body: "The facility is just ahead.")
            case .far:
                sendBeaconNotification(title: "Keep going!", body: "The facility is a bit further away.")
            default:
                print("DEBUG: No proximity detected.")
            }
        }
    }
    
    // Send notification to the user for beacon proximity
    private func sendBeaconNotification(title: String, body: String) {
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


    
    // Update user's current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }
    
    // Handle geofence entry event
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        sendNotification(for: circularRegion, entered: true)
    }
    
    // Handle geofence exit event
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        sendNotification(for: circularRegion, entered: false)
    }
    
    // Send notification to the user
    private func sendNotification(for region: CLCircularRegion, entered: Bool) {
        let content = UNMutableNotificationContent()
        content.title = entered ? "Welcome!" : "Goodbye!"
        content.body = entered ? "You are near \(region.identifier)." : "You have left \(region.identifier)."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG: Error adding notification: \(error.localizedDescription)")
            }
        }
    }
}
