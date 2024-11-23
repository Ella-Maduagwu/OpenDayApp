import Foundation
import CoreLocation
import UserNotifications
import FirebaseFirestore

class GeolocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = GeolocationManager()  // Singleton instance
    
    private var locationManager: CLLocationManager?
    private var monitoredRegions: [CLCircularRegion] = []
    var currentLocation: CLLocation?  // Stores the user's current location
    weak var delegate: CLLocationManagerDelegate?
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()  // Continuously updates the user's current location
    }
    
    // Function to get the current user location
    func getCurrentLocation() -> CLLocation? {
        return currentLocation  // Returns the most recently updated location
    }
    
    // Add the function to set up geofencing
    func setupGeofencing(for db: Firestore, collection: String) {
        db.collection(collection).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, error == nil else {
                print("Error fetching buildings: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            documents.forEach { document in
                let buildingData = document.data()
                if let name = buildingData["name"] as? String,
                   let latitude = buildingData["latitude"] as? Double,
                   let longitude = buildingData["longitude"] as? Double {
                    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: 100, identifier: name)
                    region.notifyOnEntry = true
                    region.notifyOnExit = true
                    
                    self.monitoredRegions.append(region)
                    self.locationManager?.startMonitoring(for: region)  // Start monitoring for this region
                }
            }
        }
    }
    
    // CLLocationManagerDelegate methods to handle location and geofence events
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location  // Updates the currentLocation when the user moves
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        sendNotification(for: circularRegion, entered: true)
        NotificationCenter.default.post(name: .didEnterGeofencedRegion, object: nil, userInfo: ["region": circularRegion])
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        sendNotification(for: circularRegion, entered: false)
        NotificationCenter.default.post(name: .didExitGeofencedRegion, object: nil, userInfo: ["region": circularRegion])
    }
    
    // Function to send local notification for entering or exiting a region
    private func sendNotification(for region: CLCircularRegion, entered: Bool) {
        let content = UNMutableNotificationContent()
        content.title = entered ? "Welcome!" : "Goodbye!"
        content.body = entered ? "You are near \(region.identifier)." : "You have left \(region.identifier)."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
}

// Define notification names for region entry and exit events.
extension Notification.Name {
    static let didEnterGeofencedRegion = Notification.Name("didEnterGeofencedRegion")
    static let didExitGeofencedRegion = Notification.Name("didExitGeofencedRegion")
}
