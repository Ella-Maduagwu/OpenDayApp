import UIKit
import MapKit
import CoreLocation
import FirebaseFirestore

class AccessibilityViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let db = Firestore.firestore()
    
    @IBOutlet weak var toiletsButton: UIButton!
    @IBOutlet weak var elevatorButton: UIButton!
    @IBOutlet weak var cafeteriaButton: UIButton!
    var buildings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView() // Set up the collection view with layout and delegate settings
        setupAccessibility() // Set up accessibility for better user experience
        setupHeader()
        fetchBuildings() // Fetch building names from Firestore
        // Set up geofencing using Firestore and buildings collection
       // GeolocationManager.shared.setupGeofencing
        
        
        //sets up button action
        toiletsButton.addTarget(self, action: #selector(navigateToNearestBuildingWithFacility(_:)), for: .touchUpInside)
        elevatorButton.addTarget(self, action: #selector(navigateToNearestBuildingWithFacility(_:)), for: .touchUpInside)
        cafeteriaButton.addTarget(self, action: #selector(navigateToNearestBuildingWithFacility(_:)), for: .touchUpInside)
    }
    
    // Configures the collection view layout, delegate, and data source.
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.view.frame.width / 2 - 35, height: self.view.frame.width / 2 - 35)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BuildingCollectionViewCell.self, forCellWithReuseIdentifier: BuildingCollectionViewCell.identifier)
    }
    
    // Configures accessibility properties for the collection view.
    private func setupAccessibility() {
        collectionView.isAccessibilityElement = true
        collectionView.accessibilityLabel = "Building List"
        collectionView.accessibilityTraits = .allowsDirectInteraction
    }
    
    
    
    // Fetches buildings from Firestore to populate the collection view.
    private func fetchBuildings() {
        let buildingsCollection = db.collection("buildings")
        
        buildingsCollection.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG: Error occurred while fetching buildings: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("DEBUG: No building documents found.")
                return
            }
            
            self.buildings.removeAll()
            for document in documents {
                if let buildingName = document.data()["name"] as? String {
                    self.buildings.append(buildingName)
                } else {
                    print("DEBUG: Building document \(document.documentID) does not contain a 'name' field.")
                }
            }
            
            DispatchQueue.main.async {
                print("DEBUG: Reloading collectionView with \(self.buildings.count) buildings.")
                self.collectionView.reloadData()
            }
        }
    }
    
    // Sets up the header for the page with the title.
    private func setupHeader() {
        let headerLabel = UILabel()
        headerLabel.text = "Buildings"
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Prepares for segue to the RoomsViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRooms",
           let destinationVC = segue.destination as? RoomsViewController,
           let buildingName = sender as? String {
            destinationVC.buildingName = buildingName
        }
    }
    
     // Handles navigation to the nearest building with the specified facility.
    @objc private func navigateToNearestBuildingWithFacility(_ sender: UIButton) {
        let facility: String
        switch sender {
        case toiletsButton:
            facility = "toilets"
            print("Toilets button pressed")
        case elevatorButton:
            facility = "elevator"
            print("Elevator button pressed")
        case cafeteriaButton:
            facility = "cafeteria"
            print("Cafeteria button pressed")
        default:
            print("Unknown button pressed")
            return
        }
        findNearestBuildingWithFacility(facility)// start searching for the nearest facility
    }
    
    
    // Finds the nearest building with the specified feature.
    private func findNearestBuildingWithFacility(_ facility: String) {
        guard let currentLocation = GeolocationManager.shared.currentLocation else {
            print("DEBUG: Current location is not available. Please enable location services.")
            showAlert(title: "Location Error", message: "Unable to determine your current location. Please ensure that location services are enabled and try again.")
            return
            
        }
        
        // Fetch buildings with the given feature from Firestore and find the nearest one
        db.collection("buildings").whereField(facility, isEqualTo: true).getDocuments { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("DEBUG: Error fetching buildings with feature: \(facility) - \(error?.localizedDescription ?? "Unknown error")")
                self?.showAlert(title: " facility not found", message: " no building with \(facility)found nearby." )
                return
            }
            // find the closest building based on the user's current location
            var nearestBuilding: (document: QueryDocumentSnapshot, distance: CLLocationDistance, coordinate: CLLocationCoordinate2D)?
            
            for document in documents {
                if  let latitude = document.data()["latitude"] as? Double,
                    let longitude = document.data()["longitude"] as? Double {
                    // create CLLocation for the building
                    let buildingLocation = CLLocation(latitude: latitude, longitude: longitude)
                    //calculate the distance from the user's current location
                    let distance = currentLocation.distance(from: buildingLocation)
                    // Create the coordinate
                            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    //update nearestBuilding if it's closer or if this is the first building
                    if nearestBuilding == nil || distance < nearestBuilding!.distance {
                        nearestBuilding = (document: document, distance: distance, coordinate: coordinate)
                    }
                }
            }
            
            guard let closestBuilding = nearestBuilding else {
                self?.showAlert(title: " facility not found", message: " no nearby buildings with \(facility) available")
                return
            }
            self?.navigateToBuilding( closestBuilding.document, facility: facility, coordinate: closestBuilding.coordinate)
        }
    }
    // navigates to the building and sets up beacon monitioring for the requested facility
    private func navigateToBuilding(_ building: QueryDocumentSnapshot, facility: String, coordinate: CLLocationCoordinate2D) {
        //Pass coordinate as an arguement
        let placemark = MKPlacemark( coordinate: coordinate)
        guard let name = building.data()["name"] as? String,
              let major = building.data()["major"]as? CLBeaconMajorValue else {
            showAlert(title: " Error", message: " Builidng data is incomplete. ")
            return
        }
        
        print(" DEBUG: Navigating to building: \(name). Setting up beacons for \(facility).")
        
        //setup becon monitoring for the building
        GeolocationManager.shared.setupBeaconRegion(for: name)
        
        //begin indoor navigation using the minor values of rooms in the building
        let roomsRef = building.reference.collection("rooms").whereField("facility", isEqualTo: facility)
        roomsRef.getDocuments{ [weak self] (querySnapshot,error) in
            guard let rooms = querySnapshot?.documents, !rooms.isEmpty, error == nil else{
                self?.showAlert(title: "Room not found", message: "No rooms with \(facility) available in \(name).")
                return
            }
            rooms.forEach { room in
                if let minor = room.data()["minor"] as? CLBeaconMinorValue{
                    print("DEBUG: Monitoring beacon with major: \(major), minor: \(minor).")
                    GeolocationManager.shared.startBeaconRanging(for: major, minor:minor)
                }
            }
            
        }
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
        }
}



extension AccessibilityViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// Returns the number of items in the section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buildings.count
    }
    
    /// Configures the cell for each item in the collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BuildingCollectionViewCell.identifier, for: indexPath) as? BuildingCollectionViewCell else {
            assertionFailure("Failed to dequeue BuildingCollectionViewCell") // Assert failure if cell cannot be dequeued
            
            return UICollectionViewCell()
        }
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemYellow]

        cell.configure(with: buildings[indexPath.row]) // Configure the cell with the building name
        cell.contentView.backgroundColor = colors[indexPath.item % colors.count]
            cell.contentView.layer.cornerRadius = 5
            //cell.contentView.layer.masksToBounds = true
        return cell
       
    }
    
    /// Handles the selection of a cell in the collection view.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBuilding = buildings[indexPath.row]
        let roomsVC = storyboard?.instantiateViewController(withIdentifier: "RoomsViewController") as! RoomsViewController
        roomsVC.buildingName = selectedBuilding
        navigationController?.pushViewController(roomsVC, animated: true) // Trigger segue to RoomsViewController
    }
    
    /// Shows an alert with a given title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message body of the alert.
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }

}
